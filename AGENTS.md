# Agentic AI Instructions

This file contains instructions for AI agents working on this repository.

## Repository Overview

This repository contains example models demonstrating how to use [Morphir](https://github.com/finos/morphir) to model business logic. Morphir is a multi-language system that captures an application's domain model and business logic in a technology-agnostic manner, enabling code generation to various target languages.

The repository includes:
- **Business Rules**: Examples of modeling business rules in Elm (traditionally implemented using rules engines)
- **Regulatory Reporting**: Examples of modeling regulatory reporting with complex calculations (e.g., LCR - Liquidity Coverage Ratio)
- **Business Applications**: Examples of modeling entire business applications and their interactions

All models are written in [Elm](https://elm-lang.org/) and compiled to Morphir IR (Intermediate Representation), which can then be transpiled to various target languages like Java, Scala, or Spring Boot.

## Toolchains

This project uses several toolchains for development:

### Task Management: mise (formerly rtx)
- **Purpose**: Manages tool versions and orchestrates development tasks
- **Configuration**: `.mise.toml` defines all available tasks
- **Key Features**: 
  - Automatic tool version management (Node.js, Elm, actionlint)
  - Task dependency resolution and caching
  - Smart rebuilds based on source file changes

### Language & Runtime
- **Elm 0.19.1**: Functional programming language used to write business logic models
- **Node.js 24**: JavaScript runtime for running build tools and tests

### Build Tools
- **morphir-elm**: Compiles Elm code to Morphir IR (JSON format)
- **elm-test-rs**: Fast test runner for Elm tests (replaces the older `lobo` test runner)
- **elm-format**: Code formatter for Elm code

### Code Quality
- **elm-format**: Ensures consistent code formatting
- **actionlint**: Lints GitHub Actions workflow files
- **Husky**: Git hooks for pre-push verification

### Development Workflow
All development tasks are managed through mise. See [DEVELOPING.md](DEVELOPING.md) for detailed documentation on:
- Setting up the development environment
- Running all available tasks
- Common development workflows
- Task descriptions and usage

Key tasks include:
- `setup`: Initial project setup
- `build`: Build Elm and Morphir IR
- `test`: Run tests
- `format`: Format code
- `verify`: Run all quality checks (lint, format-check, test)
- `clean`: Clean build outputs

## Commit Guidelines

- Do NOT add `Co-Authored-By` trailers for AI assistants in commit messages
- Write clear, concise commit messages that describe the change
- Use sentence case for commit messages

## GitHub Actions Workflows

When working with GitHub Actions workflows, follow these guidelines:

### Use Mise Tasks Instead of Inline Scripts

**Principle**: Avoid large inline scripts in workflow files. Instead, create TypeScript scripts and mise tasks.

**Pattern**:
1. Create a TypeScript script in `scripts/` directory
2. Add a corresponding mise task in `.mise.toml`
3. Use the mise task in the workflow

**Benefits**:
- **Testability**: Scripts can be tested locally with `mise run <task-name>`
- **Maintainability**: Centralized logic in version-controlled scripts
- **Reusability**: Tasks can be used in multiple workflows or locally
- **Type Safety**: TypeScript provides better error checking and IDE support
- **Readability**: Workflows remain clean and declarative

**Example**:
```yaml
# ❌ Bad: Large inline script
- name: Do something
  run: |
    # 20+ lines of bash script here
    ...

# ✅ Good: Use mise task
- name: Do something
  run: mise run task-name arg1 arg2
```

**When to create a script**:
- Any script longer than 3-5 lines
- Logic that might be reused
- Complex conditional logic
- Operations that benefit from type checking

## Code Owners

- The `@finos/morphir-maintainers` team owns this repository
- All pull requests require review from code owners
