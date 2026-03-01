#!/usr/bin/env node

import { runPass } from '../lib/loop.js';
import path from 'node:path';

const args = process.argv.slice(2);
const flags = args.filter(a => a.startsWith('--'));
const positional = args.filter(a => !a.startsWith('--'));

if (positional.length === 0) {
  console.error('Usage: node bin/validate.js <design-dir> [--render-only] [--analyze-only]');
  process.exit(1);
}

const designDir = path.resolve(positional[0]);
const options = {
  renderOnly: flags.includes('--render-only'),
  analyzeOnly: flags.includes('--analyze-only'),
};

try {
  const report = await runPass(designDir, options);

  console.log(JSON.stringify(report, null, 2));

  if (!report.pass) {
    console.error('\nValidation FAILED');
    if (report.validation?.errors?.length) {
      console.error('\nErrors:');
      for (const err of report.validation.errors) {
        console.error(`  ${err.name}: expected ${err.expected}, got ${err.actual} (diff: ${err.diff ?? 'n/a'})`);
      }
    }
    process.exit(1);
  } else {
    console.error('\nValidation PASSED');
  }
} catch (err) {
  console.error('Fatal error:', err.message);
  process.exit(2);
}
