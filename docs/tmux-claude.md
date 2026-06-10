# tmux Session Workflow

Persistent tmux sessions with a standard layout. All helpers live in `shell/_tmux`.

## Mental model

```
Session  tx-<project>            →  project (one per repo / feature)
Window   dev | test | infra      →  task / workflow step
Pane     agent | shell | logs    →  runtime component
```

## Commands

| Command            | What it does                                              |
| ------------------ | --------------------------------------------------------- |
| `txnew [project]`  | Create a new session (project defaults to `basename $PWD`)|
| `txopen`           | fzf-select a `tx-*` session to attach                     |
| `txclose`          | fzf-select a `tx-*` session to kill                       |

## Standard layout

```
tx-myproj
├── dev      [0] agent     [1] shell     [2] logs/tail
├── test     [0] runner    [1] agent (review)
└── infra    [0] htop / logs
```

## Resume after reboot

`tmux-resurrect` + `tmux-continuum` auto-save/restore sessions:

```bash
tmux            # continuum auto-restores the last snapshot
tmux ls         # confirm tx-* sessions are back
tmux attach -t tx-myproj
```

**Manual save/restore (if you need it)**

- Save now: `Prefix + Ctrl-s`
- Restore: `Prefix + Ctrl-r`

**Caveats**

- `claude -c` picks the most recent session in the pane's cwd. If you
  had multiple Claude conversations in the same directory, use
  `claude -r` interactively to choose.
- In-flight tool calls / pending state aren't preserved — you resume
  from the last saved message.
- First boot after install: run `mise run setup-tmux` once so tpm and
  the plugins land in `~/.tmux/plugins/`.
