import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import path from 'node:path';
import { analyzeSTL } from '../lib/stl-analyze.js';

const FIXTURES = path.join(import.meta.dirname, 'fixtures');

describe('analyzeSTL', () => {
  it('returns correct bbox for a 10mm cube', () => {
    const result = analyzeSTL(path.join(FIXTURES, 'cube-10mm.stl'));

    assert.equal(result.bbox.x, 10, 'bbox.x should be 10');
    assert.equal(result.bbox.y, 10, 'bbox.y should be 10');
    assert.equal(result.bbox.z, 10, 'bbox.z should be 10');
  });

  it('reports volume for a 10mm cube', () => {
    const result = analyzeSTL(path.join(FIXTURES, 'cube-10mm.stl'));

    // 10mm cube = 1000mm³ = 1cm³
    assert.ok(Math.abs(result.volume - 1.0) < 0.01, `volume should be ~1.0 cm³, got ${result.volume}`);
  });

  it('reports watertight for a closed cube', () => {
    const result = analyzeSTL(path.join(FIXTURES, 'cube-10mm.stl'));

    assert.equal(result.isWatertight, true, 'cube should be watertight');
  });

  it('returns center of mass near center of cube', () => {
    const result = analyzeSTL(path.join(FIXTURES, 'cube-10mm.stl'));

    assert.ok(Math.abs(result.centerOfMass.x - 5) < 0.5, `CoM x should be ~5, got ${result.centerOfMass.x}`);
    assert.ok(Math.abs(result.centerOfMass.y - 5) < 0.5, `CoM y should be ~5, got ${result.centerOfMass.y}`);
    assert.ok(Math.abs(result.centerOfMass.z - 5) < 0.5, `CoM z should be ~5, got ${result.centerOfMass.z}`);
  });
});
