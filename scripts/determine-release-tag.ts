#!/usr/bin/env tsx

/**
 * Determines the release tag based on the event type.
 * For workflow_dispatch, uses the provided version input.
 * For tag push events, extracts the tag from GITHUB_REF.
 * 
 * Usage: determine-release-tag.ts <event-name> [version-input] [github-ref]
 */

const args = process.argv.slice(2);

if (args.length < 1) {
  console.error('Usage: determine-release-tag.ts <event-name> [version-input] [github-ref]');
  console.error('Example: determine-release-tag.ts workflow_dispatch v1.0.0');
  console.error('Example: determine-release-tag.ts push "" refs/tags/v1.0.0');
  process.exit(1);
}

const [eventName, versionInput, githubRef] = args;

let tag: string;

if (eventName === 'workflow_dispatch') {
  if (!versionInput) {
    console.error('Error: version input is required for workflow_dispatch events');
    process.exit(1);
  }
  tag = versionInput;
} else {
  // Extract tag from GITHUB_REF (format: refs/tags/v1.0.0)
  if (!githubRef || !githubRef.startsWith('refs/tags/')) {
    console.error('Error: Invalid GITHUB_REF format. Expected refs/tags/<tag>');
    process.exit(1);
  }
  tag = githubRef.replace('refs/tags/', '');
}

console.log(tag);
