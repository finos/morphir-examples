#!/usr/bin/env tsx

import { execSync } from 'child_process';

/**
 * Generates release notes for a given tag by comparing it to the previous tag.
 * 
 * @param tag - The version tag (e.g., "v1.0.0")
 * @param repositoryUrl - The GitHub repository URL (e.g., "https://github.com/owner/repo")
 * @returns The formatted release notes
 */
function generateReleaseNotes(tag: string, repositoryUrl: string): string {
  try {
    // Fetch all tags to ensure we have the latest
    execSync('git fetch --tags --force', { stdio: 'inherit' });

    // Get all tags sorted by version (newest first)
    const allTagsOutput = execSync('git tag --sort=-version:refname', { encoding: 'utf-8' });
    const allTags = allTagsOutput.trim().split('\n').filter(t => t.length > 0);

    // Find the previous tag (skip the current tag if it exists)
    const currentTagIndex = allTags.indexOf(tag);
    const previousTag = currentTagIndex >= 0 && currentTagIndex < allTags.length - 1
      ? allTags[currentTagIndex + 1]
      : allTags.length > 0 && allTags[0] !== tag
        ? allTags[0]
        : null;

    let commits: string[];
    let changelogUrl: string;

    if (!previousTag) {
      // No previous tag, get all commits
      const commitsOutput = execSync('git log --pretty=format:"- %s (%h)" --no-merges', { encoding: 'utf-8' });
      commits = commitsOutput.trim().split('\n').filter(c => c.length > 0);
      changelogUrl = `${repositoryUrl}/compare/${tag}`;
    } else {
      // Get commits between previous tag and current
      const commitsOutput = execSync(
        `git log ${previousTag}..HEAD --pretty=format:"- %s (%h)" --no-merges`,
        { encoding: 'utf-8' }
      );
      commits = commitsOutput.trim().split('\n').filter(c => c.length > 0);
      changelogUrl = `${repositoryUrl}/compare/${previousTag}...${tag}`;
    }

    // Build the release notes
    const notes = [
      '## What\'s Changed',
      '',
      ...commits,
      '',
      `**Full Changelog**: ${changelogUrl}`
    ].join('\n');

    return notes;
  } catch (error) {
    console.error('Error generating release notes:', error);
    process.exit(1);
  }
}

// Main execution
const args = process.argv.slice(2);

if (args.length < 1) {
  console.error('Usage: generate-release-notes.ts <tag> [repository-url]');
  console.error('Example: generate-release-notes.ts v1.0.0');
  console.error('Example: generate-release-notes.ts v1.0.0 https://github.com/owner/repo');
  process.exit(1);
}

const tag = args[0];
const repositoryUrl = args[1] || 'https://github.com/finos/morphir-examples';
const releaseNotes = generateReleaseNotes(tag, repositoryUrl);
console.log(releaseNotes);
