import path from 'node:path';
import { mkdir } from 'node:fs/promises';
import { renderSTL } from './openscad.js';
import { analyzeSTL } from './stl-analyze.js';
import { validateSpec } from './validate.js';
import { renderViews } from './render-views.js';

/**
 * Run a single validation pass for a design.
 * The agent controls looping externally — this is a pure single-pass tool.
 *
 * @param {string} designDir - path to design directory (e.g., designs/vent-adapter)
 * @param {Object} [options]
 * @param {boolean} [options.renderOnly] - only render STL + PNGs, skip validation
 * @param {boolean} [options.analyzeOnly] - skip rendering, use existing STL
 * @returns {Promise<Object>} structured report
 */
export async function runPass(designDir, options = {}) {
  const designName = path.basename(designDir);
  const scadPath = path.join(designDir, `${designName}.scad`);
  const specPath = path.join(designDir, 'spec.json');
  const outputDir = path.join(designDir, 'output');
  const stlPath = path.join(outputDir, `${designName}.stl`);

  await mkdir(outputDir, { recursive: true });

  const report = { designName, steps: [] };

  // Step 1: Render STL
  let renderResult = null;
  if (!options.analyzeOnly) {
    try {
      renderResult = await renderSTL(scadPath, stlPath);
      report.steps.push({ step: 'render-stl', status: 'ok', echoes: renderResult.echoes });
    } catch (err) {
      report.steps.push({ step: 'render-stl', status: 'error', error: err.message, stderr: err.stderr });
      report.pass = false;
      return report;
    }
  }

  // Step 2: Render PNGs
  if (!options.analyzeOnly) {
    try {
      const viewResult = await renderViews(scadPath, outputDir);
      report.steps.push({ step: 'render-views', status: 'ok', views: viewResult.views.map(v => v.path) });
    } catch (err) {
      report.steps.push({ step: 'render-views', status: 'error', error: err.message });
    }
  }

  if (options.renderOnly) {
    report.pass = true;
    return report;
  }

  // Step 3: Analyze STL
  let analysis;
  try {
    analysis = analyzeSTL(stlPath);
    report.steps.push({ step: 'analyze', status: 'ok', analysis });
  } catch (err) {
    report.steps.push({ step: 'analyze', status: 'error', error: err.message });
    report.pass = false;
    return report;
  }

  // Step 4: Validate against spec
  try {
    const validation = await validateSpec(analysis, specPath, renderResult?.dimensions ?? {});
    report.steps.push({ step: 'validate', status: 'ok', validation });
    report.pass = validation.pass;
    report.validation = validation;
  } catch (err) {
    report.steps.push({ step: 'validate', status: 'error', error: err.message });
    report.pass = false;
  }

  return report;
}
