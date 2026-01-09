#!/usr/bin/env tsx

import { execSync } from 'child_process';
import { existsSync } from 'fs';

/**
 * Creates a gzipped tar archive containing all Morphir IR artifacts.
 * 
 * @param version - The version tag (e.g., "v1.0.0")
 * @returns The name of the created archive file
 */
function createMorphirArchive(version: string): string {
  const archiveName = `morphir-ir-${version}.tar.gz`;
  
  const requiredFiles = [
    'morphir-ir.json',
    'morphir-interface.json',
    'morphir-implementation.json',
    'morphir-version.json'
  ];

  // Check that all required files exist
  const missingFiles = requiredFiles.filter(file => !existsSync(file));
  if (missingFiles.length > 0) {
    console.error(`Error: Required files are missing: ${missingFiles.join(', ')}`);
    console.error('Please run the build task first to generate Morphir IR files.');
    process.exit(1);
  }

  try {
    // Create the archive
    execSync(
      `tar -czf "${archiveName}" ${requiredFiles.join(' ')}`,
      { stdio: 'inherit' }
    );
    
    console.log(`Created archive: ${archiveName}`);
    return archiveName;
  } catch (error) {
    console.error('Error creating archive:', error);
    process.exit(1);
  }
}

// Main execution
const args = process.argv.slice(2);

if (args.length < 1) {
  console.error('Usage: create-morphir-archive.ts <version>');
  console.error('Example: create-morphir-archive.ts v1.0.0');
  process.exit(1);
}

const version = args[0];
const archiveName = createMorphirArchive(version);
console.log(archiveName);
