# Development Guide

This guide explains how to work with this repository, including how to set up your development environment and run all available tasks.

## Prerequisites

This project uses [mise](https://mise.jdx.dev/) (formerly rtx) to manage tool versions and tasks. Make sure you have mise installed before proceeding.

The project requires:
- Node.js 24
- Elm 0.19.1
- actionlint 1.7.10

All tools are automatically installed by mise when you run tasks.

## Initial Setup

To set up the project for the first time, run:

```bash
mise run setup
```

This will:
- Install all npm dependencies
- Install Elm dependencies
- Install Elm test dependencies
- Set up Husky git hooks

## Available Tasks

All tasks are run using `mise run <task-name>`. Here's a comprehensive guide to all available tasks:

### Setup Tasks

#### `setup`
Complete project setup including dependencies and git hooks.

```bash
mise run setup
```

#### `husky-setup`
Set up Husky git hooks (automatically runs as part of `setup`).

```bash
mise run husky-setup
```

### Dependency Management Tasks

#### `npm-install`
Install npm dependencies. This task is cached and will only re-run when `package.json` or `package-lock.json` changes.

```bash
mise run npm-install
```

#### `elm-install`
Install Elm dependencies. This task is cached and will only re-run when `elm.json` or source files change.

```bash
mise run elm-install
```

#### `elm-test-install`
Install Elm test dependencies. This task is cached and will only re-run when `elm.json` or test files change.

```bash
mise run elm-test-install
```

### Restore Tasks

These tasks ensure dependencies are installed without running builds or tests. Useful for CI/CD or when you want to restore dependencies.

#### `restore`
Restore project dependencies (npm and Elm).

```bash
mise run restore
```

#### `restore-test-dependencies`
Restore test dependencies (Elm test packages).

```bash
mise run restore-test-dependencies
```

#### `restore-all`
Restore all project and test dependencies.

```bash
mise run restore-all
```

### Build Tasks

#### `build`
Build both Elm and Morphir. This is the main build task.

```bash
mise run build
```

#### `elm-build`
Build and validate Elm code.

```bash
mise run elm-build
```

#### `morphir-build`
Generate Morphir IR from Elm sources.

```bash
mise run morphir-build
```

### Format Tasks

#### `format`
Format all Elm code in `src/` and `tests/` directories using `elm-format`.

```bash
mise run format
```

#### `format-check`
Check if Elm code is properly formatted without making changes. This is useful for CI/CD.

```bash
mise run format-check
```

### Test Tasks

#### `test`
Run all tests using `elm-test-rs`.

```bash
mise run test
```

### Lint Tasks

#### `lint`
Run all linting tasks (currently includes workflow linting).

```bash
mise run lint
```

#### `lint-workflows`
Lint GitHub Actions workflow YAML files using `actionlint`.

```bash
mise run lint-workflows
```

### Verification Tasks

#### `verify`
Run all code quality checks: lint, format-check, and test. This is the comprehensive verification task.

```bash
mise run verify
```

This task is also run automatically by the pre-push git hook to ensure code quality before pushing.

### Clean Tasks

#### `clean`
Clean all build outputs (npm, Elm, and Morphir).

```bash
mise run clean
```

#### `clean-npm`
Clean npm build outputs (`node_modules/`).

```bash
mise run clean-npm
```

#### `clean-elm`
Clean Elm build outputs (`elm-stuff/`).

```bash
mise run clean-elm
```

#### `clean-morphir`
Clean Morphir build outputs (IR JSON files).

```bash
mise run clean-morphir
```

### Other Tasks

#### `train-build-release`
Run the train-build-release tool.

```bash
mise run train-build-release
```

## Common Workflows

### Starting a New Feature

1. Set up the project (if not already done):
   ```bash
   mise run setup
   ```

2. Make your changes to the code

3. Format your code:
   ```bash
   mise run format
   ```

4. Run tests:
   ```bash
   mise run test
   ```

5. Verify everything:
   ```bash
   mise run verify
   ```

6. Commit and push (the pre-push hook will run `verify` automatically)

### Before Committing

Run the verification task to ensure everything is correct:

```bash
mise run verify
```

This will:
- Lint workflow files
- Check code formatting
- Run all tests

### Cleaning Up

If you need to start fresh or free up disk space:

```bash
mise run clean
```

Then restore dependencies:

```bash
mise run restore-all
```

## Git Hooks

This project uses [Husky](https://typicode.github.io/husky/) to manage git hooks:

- **pre-push**: Automatically runs `mise run verify` before pushing to ensure code quality

The hooks are set up automatically when you run `mise run setup`.

## Task Caching

Many tasks use mise's caching mechanism to avoid unnecessary work:

- Tasks with `sources` and `outputs` defined will only re-run when source files change
- This makes subsequent runs much faster
- For example, `npm-install` only runs when `package.json` or `package-lock.json` changes

## Getting Help

To see all available tasks and their descriptions:

```bash
mise tasks ls
```

To see detailed information about a specific task:

```bash
mise tasks info <task-name>
```

To see the dependency graph for a task:

```bash
mise tasks deps <task-name>
```
