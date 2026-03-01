import { execFile, spawn } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';

const execFileAsync = promisify(execFile);

const SCAD_LIB_DIR = path.resolve(import.meta.dirname, '..', 'scad-lib');

// Display number for Xvfb (incremented to avoid conflicts)
let nextDisplay = 99;

/**
 * Run a command with a virtual X display.
 * Starts Xvfb, runs the command with DISPLAY set, then cleans up.
 */
async function withXvfb(cmd, args, options = {}) {
  const display = `:${nextDisplay++}`;

  // Start Xvfb
  const xvfb = spawn('Xvfb', [display, '-screen', '0', '1280x1024x24', '-nolisten', 'tcp'], {
    stdio: 'ignore',
    detached: true,
  });

  // Give Xvfb a moment to start
  await new Promise(r => setTimeout(r, 500));

  try {
    const result = await execFileAsync(cmd, args, {
      ...options,
      env: { ...options.env, DISPLAY: display },
    });
    return result;
  } finally {
    xvfb.kill();
  }
}

/**
 * Execute OpenSCAD with virtual display and library path.
 */
async function runOpenSCAD(args, timeout = 60_000) {
  const env = { ...process.env, OPENSCADPATH: SCAD_LIB_DIR };

  // Try xvfb-run first, fall back to manual Xvfb
  try {
    const result = await execFileAsync('xvfb-run', ['openscad', ...args], {
      timeout,
      env,
    });
    return result;
  } catch (err) {
    if (err.stderr?.includes('xauth command not found') || err.message?.includes('xauth')) {
      // xvfb-run needs xauth which isn't installed — use manual Xvfb
      return withXvfb('openscad', args, { timeout, env });
    }
    throw err;
  }
}

/**
 * Render an OpenSCAD file to STL.
 * @param {string} scadPath - path to .scad file
 * @param {string} outputPath - path for output .stl file
 * @param {Object} [params] - key/value pairs passed as -D overrides
 * @returns {Promise<{echoes: Object[], dimensions: Object, stderr: string}>}
 */
export async function renderSTL(scadPath, outputPath, params = {}) {
  const args = ['-o', outputPath];

  for (const [key, value] of Object.entries(params)) {
    args.push('-D', `${key}=${typeof value === 'string' ? `"${value}"` : value}`);
  }

  args.push(scadPath);

  const { stderr } = await runOpenSCAD(args);
  return parseStderr(stderr);
}

/**
 * Render an OpenSCAD file to PNG with specific camera angle.
 * @param {string} scadPath - path to .scad file
 * @param {string} outputPath - path for output .png file
 * @param {Object} options - rendering options
 * @param {string} options.camera - camera position "tx,ty,tz,rx,ry,rz,d"
 * @param {number[]} [options.size] - image size [width, height]
 * @param {Object} [options.params] - -D overrides
 * @returns {Promise<{echoes: Object[], dimensions: Object, stderr: string}>}
 */
export async function renderPNG(scadPath, outputPath, options = {}) {
  const args = [
    '-o', outputPath,
    '--projection=ortho',
    '--viewall',
    '--autocenter',
  ];

  if (options.camera) {
    args.push(`--camera=${options.camera}`);
  }

  if (options.size) {
    args.push(`--imgsize=${options.size[0]},${options.size[1]}`);
  }

  if (options.params) {
    for (const [key, value] of Object.entries(options.params)) {
      args.push('-D', `${key}=${typeof value === 'string' ? `"${value}"` : value}`);
    }
  }

  args.push(scadPath);

  const { stderr } = await runOpenSCAD(args);
  return parseStderr(stderr);
}

/**
 * Parse OpenSCAD stderr for ECHO lines and DIMENSION reports.
 */
function parseStderr(stderr) {
  const lines = stderr.split('\n');
  const echoes = [];
  const dimensions = {};

  for (const line of lines) {
    // Match ECHO: "..." lines
    const echoMatch = line.match(/^ECHO:\s*"(.+)"$/);
    if (echoMatch) {
      const value = echoMatch[1];

      // Check for DIMENSION:label:axis=value format
      const dimMatch = value.match(/^DIMENSION:(\w+):(\w+)=(.+)$/);
      if (dimMatch) {
        const [, label, axis, val] = dimMatch;
        if (!dimensions[label]) dimensions[label] = {};
        dimensions[label][axis] = parseFloat(val);
      }

      echoes.push(value);
    }
  }

  return { echoes, dimensions, stderr };
}
