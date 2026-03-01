import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const NodeStl = require('node-stl');

/**
 * Analyze an STL file and return measurements.
 * @param {string} stlPath - path to .stl file
 * @returns {{bbox: {x: number, y: number, z: number}, volume: number, area: number, centerOfMass: {x: number, y: number, z: number}, isWatertight: boolean}}
 */
export function analyzeSTL(stlPath) {
  const stl = new NodeStl(stlPath, { density: 1.24 }); // PLA density

  return {
    bbox: {
      x: round(stl.boundingBox[0]),
      y: round(stl.boundingBox[1]),
      z: round(stl.boundingBox[2]),
    },
    volume: round(stl.volume),
    area: round(stl.area),
    centerOfMass: {
      x: round(stl.centerOfMass[0]),
      y: round(stl.centerOfMass[1]),
      z: round(stl.centerOfMass[2]),
    },
    isWatertight: stl.isWatertight,
  };
}

function round(n, decimals = 3) {
  const factor = 10 ** decimals;
  return Math.round(n * factor) / factor;
}
