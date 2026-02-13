# Git Aliases and Helpers

This document lists git aliases from git config and git-related shell helpers from this profile.

## Git Config Aliases

```bash
up        # pull --rebase then push
lo        # log --oneline -5
lg        # log --oneline --graph --decorate -10
co        # checkout
cob       # checkout -b
br        # branch
brv       # branch -vv
st        # status
rmv       # remote -vv
branch-name  # current branch name
brd       # delete merged local branches (except main/master)
dc        # diff --cached
dcf       # diff --name-only --cached
dp        # diff HEAD^
dpf       # diff --name-only HEAD^
czs       # cz -a -s
cm        # commit -a -s
cmm       # commit -a -s -m
cma       # commit -a -s --amend
cmn       # commit -a -s --amend --no-edit
pf        # push --force-with-lease
pr        # pull --rebase
publish   # push current branch to origin with upstream
unpublish # delete remote branch for current branch
parent    # find parent branch from reflog
rb        # rebase onto parent
rbm       # fetch --prune then rebase origin/master with sign-off
rbi       # rebase -i from fork point with sign-off
rbc       # add -A and rebase --continue
rba       # rebase --abort
rs        # fetch then reset --hard to origin/<current>
undo      # reset --soft HEAD^
ss        # stash
sp        # stash pop
sd        # stash drop
sl        # stash list
nuke      # clean -fd and checkout -- .
```

## Shell Helpers (Git-Related)

### General Git

```bash
cdg   # cd to current git/worktree repository root
pgt   # prune tags (local and remote)
pgb   # prune branches (local and remote)
```

### Worktree Helpers

```bash
wtl       # list worktrees
wtm       # jump to main worktree
wtc       # create worktree (prompt to create branch if missing)
wtd       # remove worktree (interactive if no path)
wtgo      # FZF worktree selector
wtp       # prune stale worktree entries
wt-help   # show worktree doc
```

### FZF Helpers

```bash
fzco   # checkout branch via FZF
fzssh  # select SSH host and connect
fzproc # inspect process (ps + lsof)
fzport # inspect listening ports
fzpk   # kill selected processes
```

## Help

Use `git-help` to print this document in the terminal.
