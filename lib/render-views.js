import path from 'node:path';
import { mkdir } from 'node:fs/promises';
import { renderPNG } from './openscad.js';

// Camera presets: tx,ty,tz,rx,ry,rz,distance
// Using rotation-based camera (0,0,0,rx,ry,rz,0) with viewall+autocenter
const VIEWS = {
  front: { camera: '0,0,0,0,0,0,0',     label: 'Front (XZ)' },
  top:   { camera: '0,0,0,90,0,0,0',     label: 'Top (XY)' },
  right: { camera: '0,0,0,0,0,270,0',    label: 'Right (YZ)' },
  iso:   { camera: '0,0,0,55,0,25,0',    label: 'Isometric' },
};

const DEFAULT_SIZE = [800, 600];

/**
 * Render 4-view PNGs for a design.
 * @param {string} scadPath - path to .scad file
 * @param {string} outputDir - directory for output PNGs
 * @param {Object} [params] - -D overrides
 * @returns {Promise<{views: Object[]}>}
 */
export async function renderViews(scadPath, outputDir, params = {}) {
  await mkdir(outputDir, { recursive: true });

  const designName = path.basename(scadPath, '.scad');
  const views = [];

  for (const [viewName, config] of Object.entries(VIEWS)) {
    const outputPath = path.join(outputDir, `${designName}-${viewName}.png`);

    await renderPNG(scadPath, outputPath, {
      camera: config.camera,
      size: DEFAULT_SIZE,
      params,
    });

    views.push({
      name: viewName,
      label: config.label,
      path: outputPath,
    });
  }

  return { views };
}
