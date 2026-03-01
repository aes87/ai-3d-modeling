import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import path from 'node:path';
import { readFile, writeFile, mkdir, rm } from 'node:fs/promises';
import { checkAssembly } from '../lib/assembly.js';
import { hasVenv } from '../lib/python-bridge.js';

const PROJECT_ROOT = path.resolve(import.meta.dirname, '..');
const TMP_DIR = path.join(import.meta.dirname, 'fixtures', 'tmp');

describe('assembly', () => {
  describe('spec parsing', () => {
    it('rejects missing spec file', async () => {
      await assert.rejects(
        () => checkAssembly('/nonexistent/spec.json'),
        (err) => {
          assert.ok(err.message.includes('ENOENT') || err.message.includes('no such file'),
            `Expected file not found error, got: ${err.message}`);
          return true;
        }
      );
    });

    it('detects missing part STLs', async (t) => {
      const venvAvailable = await hasVenv();
      if (!venvAvailable) return t.skip('Python venv not available');

      await mkdir(TMP_DIR, { recursive: true });
      const specPath = path.join(TMP_DIR, 'test-assembly.json');
      await writeFile(specPath, JSON.stringify({
        name: 'test-assembly',
        parts: [
          { name: 'missing-part', designDir: 'designs/nonexistent-design', position: [0, 0, 0] },
        ],
        checks: { interference: [] },
        fitSpecs: [],
      }));

      const report = await checkAssembly(specPath, { skipViz: true });

      assert.equal(report.pass, false, 'Should fail with missing part');
      const verifyStep = report.steps.find(s => s.step === 'verify-parts');
      assert.ok(verifyStep, 'Should have verify-parts step');
      assert.equal(verifyStep.status, 'error');
      assert.equal(verifyStep.parts[0].status, 'missing');

      await rm(specPath);
    });
  });

  describe('integration', () => {
    it('runs full assembly check on fan-tub-adapter-v2 (skip viz)', async (t) => {
      const venvAvailable = await hasVenv();
      if (!venvAvailable) return t.skip('Python venv not available');

      // Check that the design STLs exist
      const specPath = path.join(PROJECT_ROOT, 'assemblies', 'fan-tub-adapter-v2.json');
      try {
        await readFile(specPath);
      } catch {
        t.skip('Assembly spec not found');
        return;
      }

      const report = await checkAssembly(specPath, { skipViz: true });

      assert.ok(report.name, 'Report should have a name');
      assert.ok(Array.isArray(report.steps), 'Report should have steps array');
      assert.equal(typeof report.pass, 'boolean', 'Report should have pass boolean');

      // Verify-parts step should exist
      const verifyStep = report.steps.find(s => s.step === 'verify-parts');
      assert.ok(verifyStep, 'Should have verify-parts step');
    });
  });
});
