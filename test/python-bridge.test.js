import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { runPython, hasVenv } from '../lib/python-bridge.js';

describe('python-bridge', () => {
  let venvAvailable;

  before(async () => {
    venvAvailable = await hasVenv();
  });

  describe('hasVenv', () => {
    it('returns a boolean', async () => {
      const result = await hasVenv();
      assert.equal(typeof result, 'boolean');
    });
  });

  describe('runPython', () => {
    it('throws on non-existent script', async (t) => {
      if (!venvAvailable) return t.skip('Python venv not available');

      await assert.rejects(
        () => runPython('nonexistent-script.py'),
        (err) => {
          assert.ok(err.message.includes('failed'), `Expected failure message, got: ${err.message}`);
          return true;
        }
      );
    });

    it('parses JSON output from a simple script', async (t) => {
      if (!venvAvailable) return t.skip('Python venv not available');

      // Use python -c via a tiny wrapper — but we test the real path
      // by running a script that just outputs JSON
      const { writeFile, unlink } = await import('node:fs/promises');
      const path = await import('node:path');
      const scriptPath = path.join(import.meta.dirname, '..', 'python', '_test_echo.py');

      await writeFile(scriptPath, 'import json; print(json.dumps({"ok": True, "value": 42}))');
      try {
        const result = await runPython('_test_echo.py');
        assert.deepEqual(result, { ok: true, value: 42 });
      } finally {
        await unlink(scriptPath);
      }
    });

    it('throws on invalid JSON output', async (t) => {
      if (!venvAvailable) return t.skip('Python venv not available');

      const { writeFile, unlink } = await import('node:fs/promises');
      const path = await import('node:path');
      const scriptPath = path.join(import.meta.dirname, '..', 'python', '_test_bad_json.py');

      await writeFile(scriptPath, 'print("not json")');
      try {
        await assert.rejects(
          () => runPython('_test_bad_json.py'),
          (err) => {
            assert.ok(err.message.includes('invalid JSON'), `Expected invalid JSON error, got: ${err.message}`);
            return true;
          }
        );
      } finally {
        await unlink(scriptPath);
      }
    });

    it('respects timeout', async (t) => {
      if (!venvAvailable) return t.skip('Python venv not available');

      const { writeFile, unlink } = await import('node:fs/promises');
      const path = await import('node:path');
      const scriptPath = path.join(import.meta.dirname, '..', 'python', '_test_slow.py');

      await writeFile(scriptPath, 'import time; time.sleep(10); print("{}")');
      try {
        await assert.rejects(
          () => runPython('_test_slow.py', [], { timeout: 1000 }),
          (err) => {
            assert.ok(err.message.includes('failed'), `Expected timeout error, got: ${err.message}`);
            return true;
          }
        );
      } finally {
        await unlink(scriptPath);
      }
    });
  });
});
