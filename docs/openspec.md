# OpenSpec workflow

This repository uses the `html-design` bundle from
[Mission Control](https://github.com/moonrockz/mission-control/tree/main/apps/openspec-ext).
New changes produce a proposal, capability specs, a standalone `design.html`
with inline CSS and SVG, and implementation tasks. Existing changes retain their
recorded schema. Follow this repository's contribution and approval rules.

## Bootstrap

Install [mise](https://mise.jdx.dev/), then run `mise install`. OpenSpec is pinned
to 1.14.3. MoonBit 0.10.18+6c83a7f62 runs the shared checker; it does not change
the project's implementation language. Existing project runtime pins remain in
place. The binary archive installed by mise does not include core or moonx, so
the mise postinstall hook completes the SDK inside the mise installation. On
Linux and macOS it runs the upstream Unix installer for the exact pinned version.
On Windows it runs `tools/bootstrap-moonbit-windows.ps1`, which downloads the
pinned core, checks its SHA-256 digest from `tools/moonbit-core-pin.json` and
bundles it. Windows on Arm uses the x64 build, because no arm64 build is
published. Then initialize the package registry once per machine:

```sh
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
nine managed files. Git attributes preserve LF line endings so Windows
checkouts keep those hashes. Keep the schema, templates, notices, checker and its feature
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
