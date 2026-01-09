#!/usr/bin/env tsx

import { execSync } from 'child_process';

/**
 * Triggers a release by creating and pushing a version tag.
 * This will trigger the GitHub Actions release workflow.
 * 
 * Usage: trigger-release.ts <version>
 * Example: trigger-release.ts v1.0.0
 */

const args = process.argv.slice(2);

if (args.length < 1) {
  console.error('Usage: trigger-release.ts <version>');
  console.error('Example: trigger-release.ts v1.0.0');
  console.error('');
  console.error('The version should follow semantic versioning (e.g., v1.0.0, v2.3.4)');
  process.exit(1);
}

const version = args[0];

// Validate version format (v*.*.*)
const versionPattern = /^v\d+\.\d+\.\d+(-.*)?$/;
if (!versionPattern.test(version)) {
  console.error(`Error: Invalid version format: ${version}`);
  console.error('Version must follow semantic versioning format: v<major>.<minor>.<patch>');
  console.error('Example: v1.0.0, v2.3.4, v1.0.0-beta.1');
  process.exit(1);
}

try {
  // Check if we're in a git repository
  execSync('git rev-parse --git-dir', { stdio: 'ignore' });
} catch (error) {
  console.error('Error: Not in a git repository');
  process.exit(1);
}

try {
  // Check if there are uncommitted changes
  const status = execSync('git status --porcelain', { encoding: 'utf-8' });
  if (status.trim()) {
    console.error('Error: You have uncommitted changes. Please commit or stash them before creating a release.');
    console.error('');
    console.error('Uncommitted changes:');
    console.error(status);
    process.exit(1);
  }
} catch (error) {
  console.error('Error: Failed to check git status');
  process.exit(1);
}

try {
  // Check if tag already exists
  try {
    execSync(`git rev-parse ${version}`, { stdio: 'ignore' });
    console.error(`Error: Tag ${version} already exists`);
    console.error('If you want to recreate the release, delete the tag first:');
    console.error(`  git tag -d ${version}`);
    console.error(`  git push origin :refs/tags/${version}`);
    process.exit(1);
  } catch (error) {
    // Tag doesn't exist, which is what we want
  }

  // Fetch latest tags from remote
  console.log('Fetching latest tags from remote...');
  execSync('git fetch --tags --force', { stdio: 'inherit' });

  // Create the tag
  console.log(`Creating tag ${version}...`);
  execSync(`git tag ${version}`, { stdio: 'inherit' });

  // Push the tag to trigger the release workflow
  console.log(`Pushing tag ${version} to remote...`);
  execSync(`git push origin ${version}`, { stdio: 'inherit' });

  console.log('');
  console.log(`✓ Successfully created and pushed tag ${version}`);
  console.log(`✓ Release workflow has been triggered`);
  console.log('');
  console.log(`You can monitor the release workflow at:`);
  console.log(`  https://github.com/${process.env.GITHUB_REPOSITORY || 'finos/morphir-examples'}/actions/workflows/release.yml`);
} catch (error) {
  console.error('Error: Failed to create or push tag');
  console.error(error);
  process.exit(1);
}
