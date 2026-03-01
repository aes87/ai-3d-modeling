import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';
import { access } from 'node:fs/promises';

const execFileAsync = promisify(execFile);

const PROJECT_ROOT = path.resolve(import.meta.dirname, '..');
const VENV_PYTHON = path.join(PROJECT_ROOT, '.venv', 'bin', 'python3');
const PYTHON_DIR = path.join(PROJECT_ROOT, 'python');

/**
 * Check if the Python virtual environment exists.
 * @returns {Promise<boolean>}
 */
export async function hasVenv() {
  try {
    await access(VENV_PYTHON);
    return true;
  } catch {
    return false;
  }
}

/**
 * Run a Python script from the python/ directory and return parsed JSON output.
 *
 * @param {string} scriptName - filename in python/ (e.g., 'interference.py')
 * @param {string[]} [args=[]] - CLI arguments passed to the script
 * @param {Object} [options]
 * @param {number} [options.timeout=120000] - timeout in ms
 * @returns {Promise<Object>} parsed JSON from stdout
 */
export async function runPython(scriptName, args = [], options = {}) {
  const { timeout = 120_000 } = options;
  const scriptPath = path.join(PYTHON_DIR, scriptName);

  let result;
  try {
    result = await execFileAsync(VENV_PYTHON, [scriptPath, ...args], {
      timeout,
      maxBuffer: 10 * 1024 * 1024, // 10MB
      cwd: PROJECT_ROOT,
    });
  } catch (err) {
    const stderr = err.stderr?.trim() || '';
    const message = stderr || err.message;
    const wrapped = new Error(`Python script ${scriptName} failed: ${message}`);
    wrapped.stderr = stderr;
    wrapped.exitCode = err.code;
    throw wrapped;
  }

  // Forward stderr to process.stderr for diagnostics
  if (result.stderr?.trim()) {
    process.stderr.write(`[python/${scriptName}] ${result.stderr.trim()}\n`);
  }

  // Parse JSON from stdout
  const stdout = result.stdout.trim();
  if (!stdout) {
    throw new Error(`Python script ${scriptName} produced no output`);
  }

  try {
    return JSON.parse(stdout);
  } catch (err) {
    throw new Error(`Python script ${scriptName} produced invalid JSON: ${stdout.slice(0, 200)}`);
  }
}
