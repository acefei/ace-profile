# dotfiles

[![Installation on Various OS](https://github.com/acefei/dotfiles-mise/actions/workflows/test-install.yml/badge.svg?branch=main)](https://github.com/acefei/dotfiles-mise/actions/workflows/test-install.yml)

Personal development environment for Linux and macOS, managed by [mise](https://mise.jdx.dev). Rootless - nothing requires sudo.

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/acefei/dotfiles-mise/main/install.sh | sh
```

## Project layout

```
dotfiles/
├── mise.toml               # Tools, env vars, and simple tasks
├── install.sh              # Fresh-machine bootstrap entry point
├── lib/
│   └── utils.sh            # Shared bash helpers (is_mac, download, …)
├── shell/
│   ├── profile             # Interactive shell setup, sourced from ~/.bash_profile
│   ├── dynamic_source_all  # Sources every shell/_* file at login
│   ├── _aliases
│   ├── _functions
│   ├── _fzf
│   ├── _git
│   ├── _prompt
│   └── _worktree
├── config/
│   ├── mise/tools.toml     # Tools + env, linked to ~/.config/mise/config.toml
│   ├── git/                # gitconfig, gitignore_global
│   ├── tmux/               # tmux.conf
│   └── vim/                # vimrc, plug_installer
├── agents/
│   ├── claude/             # settings.json, hooks/
│   └── vscode/             # settings.json, keybindings.json, extensions.txt
├── utility/                # Scripts symlinked to ~/.local/bin
├── templates/              # Cloud-init and Docker starter files
├── docs/                   # Reference docs (git aliases, fzf, worktrees, skill workflow)
└── .mise/tasks/            # One executable script per setup-* task
```

Two mise files, on purpose: `config/mise/tools.toml` is your **global** config
(tools available in every directory), `mise.toml` holds this repo's **tasks**.

## Philosophy

**Tools** are anything `mise` can install and version-manage. **Tasks** are idempotent scripts that wire config files, generate completions, or do one-time setup steps that a package manager can't handle.

- Prefer a tool entry when: something has versioned releases and you want `mise install` / `mise upgrade` to manage it.
- Prefer a task when: setup is stateful (symlinking, building from source, writing config files) or needs OS-aware logic.
- Keep tasks idempotent — re-running `mise run bootstrap` on an existing machine should be safe.

### Link, include, or copy

How a config file is installed depends on **who writes it**, not on how often you
change it.

| Who writes it | How it is installed | Examples |
|---|---|---|
| Only you | **Symlink** — edit it in the repo and the change is live at once; `git status` here is the whole drift report | `tmux.conf`, `vimrc`, `gitignore_global`, `utility/*`, `mise/tools.toml` |
| You **and** a tool | **Include** — one line in a machine-local file pulls in the repo file, so the tool writes locally and the repo stays clean | `~/.gitconfig`, `~/.bash_profile`, `~/.bashrc` |
| Mostly the tool | **Copy once, never clobber** — the repo file is a seed, drift is expected | Claude `settings.json`, VSCode `settings.json` / `keybindings.json` |
| You already have your own | **Adopt** — keep what is there and attach the repo's beside it | existing `~/.claude/CLAUDE.md` |

Never symlink a file a tool rewrites. `git config --global` in particular writes
*through* a symlink, so a linked `~/.gitconfig` would put machine-local values in
this repo.

An include is a single appended line in that format's own directive, so whatever
else you keep in the file survives and a re-run never adds it twice:

```gitconfig
[include]                                    # ~/.gitconfig
	path = ~/dotfiles-mise/config/git/gitconfig
```
```bash
source ~/dotfiles-mise/shell/profile         # ~/.bash_profile, ~/.bashrc
```

Because the include goes last, this repo's settings win — put machine-specific
overrides *after* it if you need the opposite.

Adoption is what the last row means: an existing `~/.claude/CLAUDE.md` gets an
`@import` of the repo file appended. Whatever was there is kept. Anything replaced is moved to `<file>.backup` exactly
once — a second run never overwrites the first backup.

`lib/utils.sh` holds one helper per strategy: `link_config`, `ensure_line`,
`copy_once`, and `backup_once` beneath them.

## Adding a tool

Add one line to `config/mise/tools.toml` under `[tools]`, then `mise install`:

```toml
[tools]
ripgrep = "latest"                    # built-in (mise registry)
"github:owner/repo" = "latest"        # any GitHub release binary
"npm:some-cli" = "latest"             # global npm package
```

## Adding a task

Write an executable script at `.mise/tasks/setup-foo` (no extension) and add
`"setup-foo"` to the `depends` list in `mise.toml`:

```bash
#!/usr/bin/env bash
#MISE description="Install foo config"
set -euo pipefail

install -m 644 "$MISE_PROJECT_ROOT/config/foo/foo.conf" "$HOME/.foo.conf"
```

`$MISE_PROJECT_ROOT` is this repo. Make it safe to re-run — `mise run bootstrap`
runs every task, and you should be able to run it any time.

## Running tasks

```bash
mise tasks                  # what's available
mise run setup-git          # just one
mise run bootstrap          # all of them, in parallel
```

## AI agent settings

`mise run setup-agents` sets up Claude Code and VSCode together. To change which
marketplaces, plugins, or skill packs you get, edit the lists at the top of
`.mise/tasks/setup-agents`.

### Claude Code plugins

What each one is for, and what it costs you in context:

| Plugin | For | Context |
| --- | --- | --- |
| `ecc` | Breadth: reviewers, build fixers and language patterns for most stacks | **~24k tok** |
| `mattpocock-skills` | Idea → spec → tickets → implementation, with grilling up front | ~1.2k tok |
| `accelerator-core` | Speak replies aloud; safe remote work over SSH | ~190 tok |
| `accelerator-loops` | Long jobs that run to a checkable finish line | ~150 tok |

That context cost is paid in **every** session. `ecc` alone is most of it — run
`claude plugin details <plugin>` for the current figure before leaving it enabled.

**VSCode** — settings, keybindings, and `extensions.txt` in `agents/vscode/`.

