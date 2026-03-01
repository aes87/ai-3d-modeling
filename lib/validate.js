import { readFile } from 'node:fs/promises';

/**
 * Validate STL analysis results against a spec.
 * @param {Object} analysis - output from analyzeSTL()
 * @param {string} specPath - path to spec.json
 * @param {Object} [echoedDimensions] - dimensions parsed from OpenSCAD ECHO output
 * @returns {Promise<{pass: boolean, checks: Object[], errors: Object[]}>}
 */
export async function validateSpec(analysis, specPath, echoedDimensions = {}) {
  const spec = JSON.parse(await readFile(specPath, 'utf-8'));
  const checks = [];
  const errors = [];

  // Check bounding box dimensions
  if (spec.dimensions) {
    for (const [axis, expected] of Object.entries(spec.dimensions)) {
      const tolerance = spec.tolerances?.[axis] ?? spec.defaultTolerance ?? 0.5;
      const actual = analysis.bbox[axis];
      const diff = Math.abs(actual - expected);
      const pass = diff <= tolerance;

      const check = {
        name: `bbox.${axis}`,
        expected,
        actual,
        tolerance,
        diff: round(diff),
        pass,
      };
      checks.push(check);
      if (!pass) errors.push(check);
    }
  }

  // Check echoed dimensions against spec
  if (spec.echoedDimensions) {
    for (const [label, axes] of Object.entries(spec.echoedDimensions)) {
      for (const [axis, expected] of Object.entries(axes)) {
        const tolerance = spec.tolerances?.[`${label}.${axis}`] ?? spec.defaultTolerance ?? 0.5;
        const actual = echoedDimensions[label]?.[axis];

        if (actual === undefined) {
          const check = { name: `echo.${label}.${axis}`, expected, actual: null, pass: false, error: 'missing echo' };
          checks.push(check);
          errors.push(check);
          continue;
        }

        const diff = Math.abs(actual - expected);
        const pass = diff <= tolerance;
        const check = { name: `echo.${label}.${axis}`, expected, actual, tolerance, diff: round(diff), pass };
        checks.push(check);
        if (!pass) errors.push(check);
      }
    }
  }

  // Check watertight
  if (spec.watertight !== undefined) {
    const pass = analysis.isWatertight === spec.watertight;
    const check = { name: 'watertight', expected: spec.watertight, actual: analysis.isWatertight, pass };
    checks.push(check);
    if (!pass) errors.push(check);
  }

  // Check max dimensions (fits on build plate)
  if (spec.maxDimensions) {
    for (const [axis, max] of Object.entries(spec.maxDimensions)) {
      const actual = analysis.bbox[axis];
      const pass = actual <= max;
      const check = { name: `maxDim.${axis}`, expected: `<= ${max}`, actual, pass };
      checks.push(check);
      if (!pass) errors.push(check);
    }
  }

  // Check volume range
  if (spec.volume) {
    const { min, max } = spec.volume;
    const actual = analysis.volume;
    const pass = actual >= min && actual <= max;
    const check = { name: 'volume', expected: `${min}–${max} cm³`, actual, pass };
    checks.push(check);
    if (!pass) errors.push(check);
  }

  return {
    pass: errors.length === 0,
    checks,
    errors,
  };
}

function round(n, decimals = 3) {
  const factor = 10 ** decimals;
  return Math.round(n * factor) / factor;
}
