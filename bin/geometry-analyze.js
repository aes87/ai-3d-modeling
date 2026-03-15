#!/usr/bin/env node

/**
 * Geometry analyzer CLI — runs mesh-based and slicer-based printability analysis.
 *
 * Usage:
 *   node bin/geometry-analyze.js designs/<name>
 *   node bin/geometry-analyze.js designs/<name> --skip-slicer
 *   node bin/geometry-analyze.js designs/<name> --skip-walls
 *   node bin/geometry-analyze.js designs/<name> --slicer-only
 *
 * Expects an STL in designs/<name>/output/<name>.stl (run validate.js first to render).
 * Outputs:
 *   designs/<name>/output/geometry-report.json   — trimesh analysis
 *   designs/<name>/output/slicer-report.json      — PrusaSlicer analysis (if available)
 */

import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';
import { access, readFile, writeFile } from 'node:fs/promises';

const execFileAsync = promisify(execFile);

const PROJECT_ROOT = path.resolve(import.meta.dirname, '..');
const VENV_PYTHON = path.join(PROJECT_ROOT, '.venv', 'bin', 'python3');
const PYTHON_DIR = path.join(PROJECT_ROOT, 'python');

async function fileExists(p) {
  try { await access(p); return true; } catch { return false; }
}

async function runPythonScript(scriptName, args, timeout = 300_000) {
  const scriptPath = path.join(PYTHON_DIR, scriptName);
  let result;
  try {
    result = await execFileAsync(VENV_PYTHON, [scriptPath, ...args], {
      timeout,
      maxBuffer: 50 * 1024 * 1024,
      cwd: PROJECT_ROOT,
    });
  } catch (err) {
    // Exit code 1 = issues found (report still written), only re-throw on real crashes
    if (err.code === 1 && err.stderr && !err.stderr.includes('Traceback')) {
      result = { stdout: err.stdout || '', stderr: err.stderr || '' };
    } else {
      throw err;
    }
  }

  if (result.stderr) {
    process.stderr.write(result.stderr);
  }

  return result.stdout.trim();
}

function usage() {
  console.error('Usage: node bin/geometry-analyze.js designs/<name> [options]');
  console.error('');
  console.error('Options:');
  console.error('  --skip-slicer    Skip PrusaSlicer analysis');
  console.error('  --skip-walls     Skip wall thickness analysis (faster)');
  console.error('  --slicer-only    Only run slicer analysis');
  console.error('  --layer-height N Layer height in mm (default: 0.2)');
  process.exit(2);
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0 || args[0] === '--help') usage();

  const designDir = path.resolve(args[0]);
  const designName = path.basename(designDir);
  const flags = new Set(args.slice(1));

  const skipSlicer = flags.has('--skip-slicer');
  const skipWalls = flags.has('--skip-walls');
  const slicerOnly = flags.has('--slicer-only');

  let layerHeight = '0.2';
  for (const flag of args) {
    if (flag.startsWith('--layer-height=')) {
      layerHeight = flag.split('=')[1];
    }
  }

  // Find STL
  const stlPath = path.join(designDir, 'output', `${designName}.stl`);
  if (!await fileExists(stlPath)) {
    console.error(`STL not found: ${stlPath}`);
    console.error('Run validation first: node bin/validate.js ' + args[0]);
    process.exit(1);
  }

  // Check Python venv
  if (!await fileExists(VENV_PYTHON)) {
    console.error('Python venv not found. Run: sudo bash setup.sh');
    process.exit(1);
  }

  const outputDir = path.join(designDir, 'output');
  const geometryReportPath = path.join(outputDir, 'geometry-report.json');
  const slicerReportPath = path.join(outputDir, 'slicer-report.json');

  let geometryResult = null;
  let slicerResult = null;

  // --- Mesh geometry analysis (trimesh) ---
  if (!slicerOnly) {
    console.log(`\n=== Mesh Geometry Analysis: ${designName} ===\n`);

    const pyArgs = [stlPath, '--layer-height', layerHeight, '--output', geometryReportPath];
    if (skipWalls) pyArgs.push('--skip-walls');

    try {
      await runPythonScript('geometry_analyze.py', pyArgs);
      const reportJson = await readFile(geometryReportPath, 'utf-8');
      geometryResult = JSON.parse(reportJson);

      const s = geometryResult.summary;
      console.log(`Mesh analysis complete:`);
      console.log(`  BBox: ${s.bbox.x} × ${s.bbox.y} × ${s.bbox.z} mm`);
      console.log(`  Layers: ${s.num_layers}`);
      console.log(`  Transitions: ${s.num_transitions}`);
      console.log(`  Overhang faces: ${s.overhangs.count || 0}`);
      console.log(`  Bridge warnings: ${s.bridge_warnings}, fails: ${s.bridge_fails}`);
      console.log(`  Thin walls: ${s.thin_walls}`);
      console.log(`  Overall: ${s.overall_pass ? 'PASS' : 'FAIL'}`);
      console.log(`  Report: ${geometryReportPath}`);
    } catch (err) {
      console.error(`Mesh analysis failed: ${err.message}`);
      if (err.stderr) console.error(err.stderr);
      process.exitCode = 1;
    }
  }

  // --- Slicer analysis (PrusaSlicer) ---
  if (!skipSlicer) {
    console.log(`\n=== Slicer Analysis: ${designName} ===\n`);

    const pyArgs = [stlPath, '--output', slicerReportPath, '--keep-gcode', '--gcode-dir', outputDir];

    try {
      await runPythonScript('slicer_analyze.py', pyArgs, 600_000);
      const reportJson = await readFile(slicerReportPath, 'utf-8');
      slicerResult = JSON.parse(reportJson);

      if (slicerResult.error) {
        console.log(`Slicer not available: ${slicerResult.error}`);
        if (slicerResult.hint) console.log(`  Hint: ${slicerResult.hint}`);
      } else {
        const s = slicerResult.summary;
        console.log(`Slicer analysis complete:`);
        console.log(`  Engine: ${slicerResult.slicer.version}`);
        console.log(`  Layers: ${s.total_layers}`);
        console.log(`  Needs support: ${s.needs_support ? 'YES' : 'no'}`);
        if (s.needs_support) {
          console.log(`  Support layers: ${s.support_layer_count}`);
          console.log(`  Support Z range: ${s.support_z_range.min}–${s.support_z_range.max} mm`);
        }
        console.log(`  Bridge layers: ${s.bridge_layer_count}`);
        console.log(`  Report: ${slicerReportPath}`);
      }
    } catch (err) {
      // Non-fatal — slicer may not be installed
      console.log(`Slicer analysis skipped: ${err.message}`);
    }
  }

  // Summary
  console.log('\n=== Summary ===\n');
  if (geometryResult) {
    console.log(`Geometry: ${geometryResult.summary.overall_pass ? 'PASS' : 'FAIL'} (${geometryResult.summary.total_issues} issues)`);
  }
  if (slicerResult && !slicerResult.error) {
    console.log(`Slicer: ${slicerResult.summary.needs_support ? 'SUPPORT NEEDED' : 'No support needed'}`);
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
