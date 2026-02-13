# Git Worktree Management

Comprehensive git worktree management tools for working with multiple branches simultaneously.

## Quick Reference

### Navigation & Listing
```bash
wtl              # List all worktrees
wtm              # Jump to main/primary worktree
wtgo             # Interactive FZF selector to jump to any worktree
```

### Creating Worktrees
```bash
wtc <branch> [path] [base]      # Create worktree; if base is set, create new branch
wtc feature-x ~/projects/feat-x # Create worktree at custom path
```

Notes:
- If the branch exists, `wtc` uses it without `-b`.
- If the branch does not exist, you will be prompted to create it.
- If three args are provided, a new branch is created using the base.
- Default path is always relative to the main repo root, even if run inside a worktree.

### Removing Worktrees
```bash
wtd <path>     # Remove worktree at specified path
wtd <path> -f  # Force remove (even if dirty or locked)
wtd            # Interactive removal with FZF (multi-select with TAB)
```

### Maintenance
```bash
wtp              # Clean up stale worktree entries
wt-help          # Show worktree documentation
```

## Common Workflows

### Quick Feature Development
```bash
# Create worktree for existing feature branch
wtc feature-authentication
cd .git-worktree/feature-authentication
# Work, commit, push
git commit -m "Add auth logic"
git push
# Clean up when done
cd -
wtd .git-worktree/feature-authentication
```

### Urgent Hotfix While Working
```bash
# Create new worktree with hotfix branch based on main
wtc hotfix-security-issue ~/hotfixes/security main
cd ~/hotfixes/security
# Fix, commit, push
git commit -m "Fix security vulnerability"
# Return to your feature work
wtgo  # Use FZF to select your original worktree
```

### Parallel Development
```bash
# Set up multiple worktrees
wtc feature-frontend
wtc feature-backend
wtc feature-api

# Switch between them using FZF
wtgo  # Select with arrows, press Enter
```

### Batch Cleanup
```bash
# Interactive multi-select removal
wtd  # Use TAB to select multiple, ENTER to confirm

# Clean up stale entries
wtp
```

## Tips & Best Practices

1. **Default paths**: Worktrees are created under `<repo-root>/.git-worktree/<branch-name>`
2. **Regular cleanup**: Run `wtp` periodically to clean up stale entries
3. **Use FZF**: `wtgo` is faster than `cd` when you have multiple worktrees
4. **Separate builds**: Each worktree has its own working directory - no rebuild when switching

## Troubleshooting

**Cannot remove non-empty worktree:**
```bash
# Option 1: Force remove
wtd .git-worktree/worktree-path -f

# Option 2: Commit or stash changes first
cd .git-worktree/worktree-path && git stash
cd - && wtd .git-worktree/worktree-path
```

**Stale worktree entries:**
```bash
# Clean up after manually deleted worktree
wtp
```

## See Also

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- Implementation: [bash_profile/_worktree](../bash_profile/_worktree)
