import path from 'node:path';
import { readFile, access, mkdir } from 'node:fs/promises';
import { renderSTL } from './openscad.js';
import { runPython, hasVenv } from './python-bridge.js';

const PROJECT_ROOT = path.resolve(import.meta.dirname, '..');

/**
 * Check assembly: verify parts, run interference checks, fit spec validation,
 * and optionally render assembly visualization.
 *
 * @param {string} specPath - path to assembly spec JSON
 * @param {Object} [options]
 * @param {boolean} [options.skipViz] - skip PyVista visualization
 * @returns {Promise<Object>} structured report
 */
export async function checkAssembly(specPath, options = {}) {
  const spec = JSON.parse(await readFile(specPath, 'utf-8'));
  const report = { name: spec.name, steps: [], pass: true };

  // Pre-check: Python venv
  if (!(await hasVenv())) {
    report.steps.push({
      step: 'check-venv',
      status: 'error',
      error: 'Python venv not found. Run: bash setup.sh',
    });
    report.pass = false;
    return report;
  }

  // Step 1: Verify all parts have STLs (render reference SCAD if needed)
  const verifyResult = await verifyParts(spec);
  report.steps.push(verifyResult);
  if (verifyResult.status === 'error') {
    report.pass = false;
    return report;
  }

  // Resolve STL paths into the spec for Python scripts
  const resolvedSpec = resolveStlPaths(spec);
  const resolvedSpecPath = path.join(PROJECT_ROOT, 'assemblies', `${spec.name}-resolved.json`);
  await mkdir(path.dirname(resolvedSpecPath), { recursive: true });
  const { writeFile } = await import('node:fs/promises');
  await writeFile(resolvedSpecPath, JSON.stringify(resolvedSpec, null, 2));

  // Step 2: Interference checks
  if (resolvedSpec.checks?.interference?.length) {
    try {
      const interferenceResult = await runPython('interference.py', [resolvedSpecPath, PROJECT_ROOT]);
      const allPass = interferenceResult.checks.every(c => c.pass);
      report.steps.push({
        step: 'interference',
        status: allPass ? 'ok' : 'fail',
        checks: interferenceResult.checks,
      });
      if (!allPass) report.pass = false;
    } catch (err) {
      report.steps.push({ step: 'interference', status: 'error', error: err.message });
      report.pass = false;
    }
  }

  // Step 3: Fit spec validation
  if (resolvedSpec.fitSpecs?.length) {
    try {
      const fitResult = await runPython('fit_check.py', [resolvedSpecPath, PROJECT_ROOT]);
      const allPass = fitResult.checks.every(c => c.pass);
      report.steps.push({
        step: 'fit-spec',
        status: allPass ? 'ok' : 'fail',
        checks: fitResult.checks,
      });
      if (!allPass) report.pass = false;
    } catch (err) {
      report.steps.push({ step: 'fit-spec', status: 'error', error: err.message });
      report.pass = false;
    }
  }

  // Step 4: Assembly visualization
  if (!options.skipViz) {
    try {
      const outputDir = path.join(PROJECT_ROOT, 'assemblies', spec.name, 'output');
      const vizResult = await runPython('assembly_render.py', [
        resolvedSpecPath, PROJECT_ROOT, outputDir,
      ]);
      report.steps.push({
        step: 'visualize',
        status: 'ok',
        views: vizResult.views,
      });
    } catch (err) {
      report.steps.push({ step: 'visualize', status: 'error', error: err.message });
      // Viz failure is non-fatal
    }
  }

  return report;
}

/**
 * Verify all parts have STL files. Render reference SCAD files if needed.
 */
async function verifyParts(spec) {
  const step = { step: 'verify-parts', status: 'ok', parts: [] };

  for (const part of spec.parts) {
    const partEntry = { name: part.name };

    if (part.designDir) {
      // Part from a design directory — STL should already exist
      const designName = path.basename(part.designDir);
      const stlPath = path.join(PROJECT_ROOT, part.designDir, 'output', `${designName}.stl`);
      try {
        await access(stlPath);
        partEntry.stlPath = stlPath;
        partEntry.status = 'found';
      } catch {
        partEntry.status = 'missing';
        partEntry.error = `STL not found: ${stlPath}. Run: node bin/validate.js ${part.designDir}`;
        step.status = 'error';
      }
    } else if (part.scadRef) {
      // Reference part — render SCAD to STL
      const scadPath = path.join(PROJECT_ROOT, part.scadRef);
      const refName = path.basename(part.scadRef, '.scad');
      const outputDir = path.join(PROJECT_ROOT, 'assemblies', 'reference-stls');
      await mkdir(outputDir, { recursive: true });
      const stlPath = path.join(outputDir, `${refName}.stl`);

      try {
        await access(stlPath);
        partEntry.stlPath = stlPath;
        partEntry.status = 'cached';
      } catch {
        // Need to render
        try {
          await renderSTL(scadPath, stlPath);
          partEntry.stlPath = stlPath;
          partEntry.status = 'rendered';
        } catch (err) {
          partEntry.status = 'render-failed';
          partEntry.error = `Failed to render ${part.scadRef}: ${err.message}`;
          step.status = 'error';
        }
      }
    } else {
      partEntry.status = 'no-source';
      partEntry.error = 'Part has neither designDir nor scadRef';
      step.status = 'error';
    }

    step.parts.push(partEntry);
  }

  return step;
}

/**
 * Resolve all STL paths in the spec to relative paths from project root.
 * This creates a copy of the spec with stlPath fields added to each part.
 */
function resolveStlPaths(spec) {
  const resolved = JSON.parse(JSON.stringify(spec));

  for (const part of resolved.parts) {
    if (part.designDir) {
      const designName = path.basename(part.designDir);
      part.stlPath = path.join(part.designDir, 'output', `${designName}.stl`);
    } else if (part.scadRef) {
      const refName = path.basename(part.scadRef, '.scad');
      part.stlPath = path.join('assemblies', 'reference-stls', `${refName}.stl`);
    }
  }

  return resolved;
}
