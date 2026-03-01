#!/usr/bin/env node

import { checkAssembly } from '../lib/assembly.js';
import path from 'node:path';

const args = process.argv.slice(2);
const flags = args.filter(a => a.startsWith('--'));
const positional = args.filter(a => !a.startsWith('--'));

if (positional.length === 0) {
  console.error('Usage: node bin/check-assembly.js <assembly-spec.json> [--skip-viz]');
  console.error('');
  console.error('Example: node bin/check-assembly.js assemblies/fan-tub-adapter-v2.json');
  process.exit(1);
}

const specPath = path.resolve(positional[0]);
const options = {
  skipViz: flags.includes('--skip-viz'),
};

try {
  const report = await checkAssembly(specPath, options);

  // JSON report to stdout
  console.log(JSON.stringify(report, null, 2));

  // Human summary to stderr
  console.error('');
  console.error(`Assembly: ${report.name}`);
  console.error('─'.repeat(40));

  for (const step of report.steps) {
    const icon = step.status === 'ok' ? 'PASS' : step.status === 'fail' ? 'FAIL' : 'ERR ';
    console.error(`  [${icon}] ${step.step}`);

    if (step.checks) {
      for (const check of step.checks) {
        const checkIcon = check.pass ? 'ok' : 'FAIL';
        const detail = check.volume !== undefined
          ? `vol=${check.volume}mm³`
          : check.actual !== undefined
            ? `actual=${check.actual}`
            : '';
        const name = check.name || `${check.partA} vs ${check.partB}`;
        console.error(`    [${checkIcon}] ${name} ${detail}`);
      }
    }

    if (step.views) {
      for (const view of step.views) {
        console.error(`    → ${view.path}`);
      }
    }

    if (step.error) {
      console.error(`    Error: ${step.error}`);
    }
  }

  console.error('─'.repeat(40));
  if (report.pass) {
    console.error('Assembly check PASSED');
  } else {
    console.error('Assembly check FAILED');
    process.exit(1);
  }
} catch (err) {
  console.error('Fatal error:', err.message);
  process.exit(2);
}
