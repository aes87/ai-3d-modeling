import path from 'node:path';
import { mkdir } from 'node:fs/promises';
import { runCLI, createProject } from './openscad.js';

/**
 * Render 4-view PNGs for a design using cli-anything-openscad.
 * Views are rendered in parallel internally by the CLI.
 *
 * @param {string} scadPath - path to .scad file
 * @param {string} outputDir - directory for output PNGs
 * @param {Object} [params] - -D overrides
 * @param {string} [projectFile] - reuse an existing project file
 * @returns {Promise<{views: Object[]}>}
 */
export async function renderViews(scadPath, outputDir, params = {}, projectFile) {
  await mkdir(outputDir, { recursive: true });

  const ownProject = !projectFile;
  if (ownProject) projectFile = await createProject(scadPath);

  try {
    // Set any -D parameter overrides (concurrent)
    if (params && Object.keys(params).length > 0) {
      await Promise.all(
        Object.entries(params).map(([key, value]) =>
          runCLI(['-p', projectFile, 'params', 'set', key, String(value)], 10_000)
        )
      );
    }

    // Render all views in parallel (CLI handles threading + Xvfb internally)
    const result = await runCLI([
      '-p', projectFile, 'render', 'views', '-o', outputDir, '--overwrite',
    ]);

    // Map CLI output to the format loop.js expects
    const views = (result.data?.views ?? []).map(v => ({
      name: v.name,
      label: v.name,
      path: v.path,
    }));

    return { views };
  } finally {
    if (ownProject) {
      try { const { unlink } = await import('node:fs/promises'); await unlink(projectFile); } catch {}
    }
  }
}
