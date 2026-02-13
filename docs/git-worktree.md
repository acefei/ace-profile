# Git Worktree Management

Comprehensive git worktree management tools for working with multiple branches simultaneously.

## Quick Reference

### Navigation & Listing
```bash
wt-list          # List all worktrees
wt-main          # Jump to main/primary worktree
wtgo             # Interactive FZF selector to jump to any worktree
```

### Creating Worktrees
```bash
wt-add <branch>                    # Create worktree from existing branch at <repo>/.git-worktree/<branch>
wt-add feature-x ~/projects/feat-x # Create worktree at custom path
wt-new <branch> [path] [base]      # Create new branch in worktree
```

### Removing Worktrees
```bash
wt-rm <path>     # Remove worktree at specified path
wt-rm <path> -f  # Force remove (even if dirty or locked)
wt-rmi           # Interactive removal with FZF (multi-select with TAB)
```

### Maintenance
```bash
wt-prune         # Clean up stale worktree entries
wt-lock <path>   # Lock worktree to prevent deletion
wt-unlock <path> # Unlock worktree
```

## Common Workflows

### Quick Feature Development
```bash
# Create worktree for existing feature branch
wt-add feature-authentication
cd .git-worktree/feature-authentication
# Work, commit, push
git commit -m "Add auth logic"
git push
# Clean up when done
cd -
wt-rm .git-worktree/feature-authentication
```

### Urgent Hotfix While Working
```bash
# Create new worktree with hotfix branch based on main
wt-new hotfix-security-issue ~/hotfixes/security main
cd ~/hotfixes/security
# Fix, commit, push
git commit -m "Fix security vulnerability"
# Return to your feature work
wtgo  # Use FZF to select your original worktree
```

### Parallel Development
```bash
# Set up multiple worktrees
wt-add feature-frontend
wt-add feature-backend
wt-add feature-api

# Switch between them using FZF
wtgo  # Select with arrows, press Enter
```

### Batch Cleanup
```bash
# Interactive multi-select removal
wt-rmi  # Use TAB to select multiple, ENTER to confirm

# Clean up stale entries
wt-prune
```

## Tips & Best Practices

1. **Default paths**: Worktrees are created under `<repo-root>/.git-worktree/<branch-name>`
2. **Regular cleanup**: Run `wt-prune` periodically to clean up stale entries
3. **Use FZF**: `wtgo` is faster than `cd` when you have multiple worktrees
4. **Separate builds**: Each worktree has its own working directory - no rebuild when switching

## Troubleshooting

**Cannot remove non-empty worktree:**
```bash
# Option 1: Force remove
wt-rm .git-worktree/worktree-path -f

# Option 2: Commit or stash changes first
cd .git-worktree/worktree-path && git stash
cd - && wt-rm .git-worktree/worktree-path
```

**Stale worktree entries:**
```bash
# Clean up after manually deleted worktree
wt-prune
```

## See Also

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- Implementation: [bash_profile/_worktree](../bash_profile/_worktree)
