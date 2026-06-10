# FZF Helpers

This repo includes a set of FZF-powered shell helpers for faster navigation and inspection.

## Quick Reference

### Git
```bash
fzco   # Checkout git branch via FZF
```

### Processes
```bash
fzpk   # Kill selected processes (FZF multi-select)
fzproc # Inspect a process (ps + lsof)
```

### SSH
```bash
fzssh  # Select SSH host from config/known_hosts and connect
```

Builds a host list from:
- `~/.ssh/config`
- `~/.ssh/config.d/*`
- `~/.ssh/known_hosts`

Then connects to the selected host.

### Ports
```bash
fzport # Inspect listening ports and owning process (lsof)
```
