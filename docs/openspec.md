# OpenSpec workflow

This repository uses the `html-design` bundle from
[Mission Control](https://github.com/moonrockz/mission-control/tree/main/apps/tools).
New changes produce a proposal, capability specs, a standalone `design.html`
with inline CSS and SVG, and implementation tasks. Existing changes retain their
recorded schema. Follow this repository's contribution and approval rules.

## Bootstrap

Install [mise](https://mise.jdx.dev/), then run `mise install`. OpenSpec is pinned
to 1.14.3. The pinned `mission-control-tools` 0.1.0 binary from
[Mission Control](https://github.com/moonrockz/mission-control/tree/main/apps/tools)
checks the shared bundle and generates the agent skills. It is a released
binary, so this repository needs no MoonBit toolchain. Existing project runtime
pins remain in place.

Then verify the checked-in bundle:

```sh
mise run openspec:verify
```

This runs `mission-control-tools openspec check --bundle` (the ownership and
version check) and the schema and change validation. An empty spec/change tree
reports no items to validate. CI runs the same checks.

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

`openspec/extensions.lock.json` (format 2) records the tool and version that
installed the bundle, and SHA-256 hashes for the seven managed files. Git
attributes preserve LF line endings so Windows checkouts keep those hashes.
Keep the schema, templates and notices identical to Mission Control. Do not
patch them locally.

To move to a new release, change the `github:moonrockz/mission-control` version
in `.mise.toml`, then run:

```sh
mise install
mise exec -- mission-control-tools openspec install
mise run openspec:verify
```

The installer refuses local edits to owned files before it writes anything. It
writes the lock last. `openspec check --bundle` fails when the lock version and
the installed tool version differ, so a version change without `install` fails
CI. See the
[mission-control-tools guide](https://github.com/moonrockz/mission-control/blob/tools-v0.1.0/apps/tools/README.md)
for the commands and their messages.

The schema's Apache-2.0 license and upstream OpenSpec MIT notice are retained in
`openspec/schemas/html-design/LICENSE` and `NOTICE`.
