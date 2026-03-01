import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { writeFile, unlink, mkdir } from 'node:fs/promises';
import path from 'node:path';
import { validateSpec } from '../lib/validate.js';

const TMP_DIR = path.join(import.meta.dirname, 'fixtures', 'tmp');

async function writeSpec(spec) {
  await mkdir(TMP_DIR, { recursive: true });
  const specPath = path.join(TMP_DIR, 'spec.json');
  await writeFile(specPath, JSON.stringify(spec));
  return specPath;
}

const CUBE_ANALYSIS = {
  bbox: { x: 10, y: 10, z: 10 },
  volume: 1.0,
  area: 600,
  centerOfMass: { x: 5, y: 5, z: 5 },
  isWatertight: true,
};

describe('validateSpec', () => {
  it('passes when dimensions match within tolerance', async () => {
    const specPath = await writeSpec({
      dimensions: { x: 10, y: 10, z: 10 },
      defaultTolerance: 0.5,
      watertight: true,
    });

    const result = await validateSpec(CUBE_ANALYSIS, specPath);
    assert.equal(result.pass, true);
    assert.equal(result.errors.length, 0);
    assert.ok(result.checks.length >= 3);
  });

  it('fails when dimensions are out of tolerance', async () => {
    const specPath = await writeSpec({
      dimensions: { x: 15, y: 10, z: 10 },
      defaultTolerance: 0.5,
    });

    const result = await validateSpec(CUBE_ANALYSIS, specPath);
    assert.equal(result.pass, false);
    assert.equal(result.errors.length, 1);
    assert.equal(result.errors[0].name, 'bbox.x');
  });

  it('fails when watertight check fails', async () => {
    const specPath = await writeSpec({
      dimensions: { x: 10, y: 10, z: 10 },
      watertight: false,
    });

    const result = await validateSpec(CUBE_ANALYSIS, specPath);
    assert.equal(result.pass, false);
    assert.ok(result.errors.some(e => e.name === 'watertight'));
  });

  it('checks volume range', async () => {
    const specPath = await writeSpec({
      volume: { min: 0.5, max: 1.5 },
    });

    const result = await validateSpec(CUBE_ANALYSIS, specPath);
    assert.equal(result.pass, true);
  });

  it('fails volume range when out of bounds', async () => {
    const specPath = await writeSpec({
      volume: { min: 2, max: 5 },
    });

    const result = await validateSpec(CUBE_ANALYSIS, specPath);
    assert.equal(result.pass, false);
    assert.ok(result.errors.some(e => e.name === 'volume'));
  });

  it('checks maxDimensions', async () => {
    const specPath = await writeSpec({
      maxDimensions: { x: 256, y: 256, z: 256 },
    });

    const result = await validateSpec(CUBE_ANALYSIS, specPath);
    assert.equal(result.pass, true);
  });

  it('validates echoed dimensions', async () => {
    const specPath = await writeSpec({
      echoedDimensions: {
        part: { x: 10, y: 10, z: 10 },
      },
      defaultTolerance: 0.5,
    });

    const echoed = { part: { x: 10, y: 10, z: 10 } };
    const result = await validateSpec(CUBE_ANALYSIS, specPath, echoed);
    assert.equal(result.pass, true);
  });

  it('fails when echoed dimension is missing', async () => {
    const specPath = await writeSpec({
      echoedDimensions: {
        part: { x: 10 },
      },
    });

    const result = await validateSpec(CUBE_ANALYSIS, specPath, {});
    assert.equal(result.pass, false);
    assert.ok(result.errors.some(e => e.error === 'missing echo'));
  });
});
