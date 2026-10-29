# OpenSpec workflow

This repository uses the `html-design` bundle from
[Mission Control](https://github.com/moonrockz/mission-control/tree/main/apps/openspec-ext).
New changes produce a proposal, capability specs, a standalone `design.html`
with inline CSS and SVG, and implementation tasks. Existing changes retain their
recorded schema. Follow this repository's contribution and approval rules.

## Bootstrap

Install [mise](https://mise.jdx.dev/), then run `mise install`. OpenSpec is pinned
to 1.14.3. MoonBit 0.10.15+943464bfa runs the shared checker; it does not change
the project's implementation language. Existing project runtime pins remain in
place. Complete the MoonBit SDK and initialize its package registry once per
machine. The binary archive installed by mise does not include core or moonx.

On Linux and macOS:

```sh
set -euo pipefail
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | \
  MOON_HOME="$(mise where http:moonbit)" bash -s -- "$(mise current http:moonbit)"
mise exec -- moon update
```

On Windows, use PowerShell:

```powershell
$env:MOON_HOME = mise where http:moonbit
$env:MOONBIT_INSTALL_VERSION = mise current http:moonbit
Invoke-RestMethod https://cli.moonbitlang.com/install/powershell.ps1 | Invoke-Expression
mise exec -- moon update
```

Then verify the checked-in bundle:

```sh
mise run openspec:verify
```

This runs the ownership check, schema and change validation, and the shared
checker's Gherkin and setup-isolation tests. An empty spec/change tree reports
no items to validate. CI runs the same checks.

## Propose and implement a change

```sh
mise exec -- openspec new change <change-name>
mise exec -- openspec instructions design --change <change-name>
```

No schema override is needed. The design instructions target `design.html`.
Use the generated core skills to propose, explore, apply, update, sync specs and
archive changes. Skills are checked in for portable/Codex agents, Claude,
Copilot, Cursor, Grok, Gemini and OpenCode. `mise run openspec:setup` regenerates
them using an isolated core profile without changing personal OpenSpec settings.

Keep project-specific context and rules in `openspec/config.yaml` and AGENTS.md.
Existing skills outside the generated OpenSpec set are preserved.

## Update the shared bundle

`openspec/extensions.lock.json` records openspec-ext 0.1.0 and SHA-256 hashes for
nine managed files. Keep the schema, templates, notices, checker and its feature
file identical to Mission Control. Do not patch them locally. The checked-in
script validates the installed snapshot against the lock; Mission Control also
compares it with the selected source bundle.

The module is not published yet. From a Mission Control checkout, use:

```sh
mise exec -- moon run apps/openspec-ext/cmd -- install /absolute/path/to/this/repository
mise exec -- moon run apps/openspec-ext/cmd -- check /absolute/path/to/this/repository
```

Review the source revision and diff, then run `mise run openspec:verify` here.
The installer refuses unmanaged conflicts and edits to owned files. It writes
the lock last. Fresh clones need neither a sibling checkout nor an unpublished
registry package to use the checked-in workflow.

The schema's Apache-2.0 license and upstream OpenSpec MIT notice are retained in
`openspec/schemas/html-design/LICENSE` and `NOTICE`.
