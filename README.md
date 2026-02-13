# Ace Profile

A unified shell environment configuration and development tools installer for Linux, macOS, and Windows.

## Features

### 🎨 Shell Configuration
- **Bash profile** with custom aliases, functions, and prompt
- **Git integration** with completion and prompt support
- **Git worktree management** - tools for working with multiple branches simultaneously ([docs](docs/git-worktree.md))
- **FZF integration** for enhanced command-line searching ([docs](docs/fzf-functions.md))
- **Tmux configuration** for terminal multiplexing
- **Vim configuration** with plugin management

### 🛠️ Development Tools
The installer automatically sets up the following tools (concurrent installation with progress indicators):
- **gitui** - Terminal UI for Git
- **ripgrep (rg)** - Fast recursive search tool
- **GitHub CLI (gh)** - Official GitHub command-line tool
- **fzf** - Fuzzy finder for command-line
- **PathPicker (fpp)** - Interactive file selector
- **uv** - Fast Python package installer
- **nvm** - Node Version Manager
- **Go** - Go programming language
- **Terraform** - Infrastructure as Code tool
- **sops** - Secret operations tool
- **age** - Modern encryption tool

### 📦 Configuration Files
- Git config template
- SSH config
- Tmux config
- Custom utility scripts
- Host file management

## Installation

### Linux or macOS

**One-line installation:**
```bash
curl -fsSL https://raw.githubusercontent.com/acefei/ace-profile/main/installer/install.sh | bash
```

Or using wget:
```bash
wget -qO- https://raw.githubusercontent.com/acefei/ace-profile/main/installer/install.sh | bash
```

**Two-step installation** (recommended for selective tool installation):
```bash
wget https://raw.githubusercontent.com/acefei/ace-profile/main/installer/install.sh
bash install.sh
```

### Windows

Press `Win + X` and select "Windows PowerShell (Admin)", then run:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/acefei/ace-profile/main/installer/setup-win.ps1'))
```

### WSL (Windows Subsystem for Linux)

If the installation fails due to DOS line endings:
```bash
wget -qO- https://raw.githubusercontent.com/acefei/ace-profile/main/installer/install.sh | tr -d '\r' | bash
```

## Usage

### Git Worktree Management

Quickly manage multiple git worktrees for parallel branch development:

```bash
wt-list          # List all worktrees
wt-main          # Jump to main worktree
wtgo             # Interactive worktree selector (FZF)
wt-add <branch>  # Create worktree from existing branch
wt-new <branch>  # Create worktree with new branch
wt-rm <path>     # Remove worktree
wt-rmi           # Batch remove with FZF
```

📖 **[Full Git Worktree Documentation](docs/git-worktree.md)** - Detailed usage, workflows, and best practices

### FZF Helpers

FZF-powered helpers for git, processes, SSH, and ports:

```bash
fzco   # Checkout git branch via FZF
fzpk   # Kill selected processes (FZF multi-select)
fzproc # Inspect a process (ps + lsof)
fzssh  # Select SSH host and connect
fzport # Inspect listening ports
```

📖 **[Full FZF Helpers Documentation](docs/fzf-functions.md)**

### Running Specific Setup Functions

To install or update a specific tool:
```bash
cd ~/.myprofile/installer
./rootless_install.sh setup_<tool_name>
```

For example:
```bash
./rootless_install.sh setup_fzf      # Install fzf
./rootless_install.sh setup_gh       # Install GitHub CLI
./rootless_install.sh setup_terraform # Install Terraform
```

### Testing Functions with Debug Mode

Run any setup function with detailed output:
```bash
./rootless_install.sh setup_gitui
```

## Post-Installation

1. **Update Git configuration**: Edit `~/.gitconfig` with your GitHub user information
2. **Re-login or source profile**: The changes take effect after re-login or run:
   ```bash
   source ~/.bash_profile
   ```

## Uninstallation

To completely remove ace-profile and all installed tools:

```bash
cd ~/.myprofile/installer
./uninstall.sh
```

The uninstaller will:
- Remove all installed tools from `~/.local/bin`
- Remove Vim plugins and configuration directories
- Restore backed up configuration files (`.bashrc`, `.bash_profile`, `.vimrc`, etc.)
- Clean up fzf, nvm, and other tool installations
- Remove the `~/.myprofile` directory

**Note**: You'll be prompted for confirmation before any files are removed.

## Directory Structure

```
~/.myprofile/
├── bash_profile/       # Shell aliases, functions, and prompt
├── config/            # Configuration templates (git, ssh, tmux)
├── installer/         # Installation scripts
├── templates/         # Project templates (docker, cloud-init)
├── utility/           # Custom utility scripts
└── vimrcs/            # Vim configuration and plugins
```

## Troubleshooting

- **Installation failed?** Re-run the specific function:
  ```bash
  ./rootless_install.sh setup_<function_name>
  ```
- **Tools not in PATH?** Make sure `~/.local/bin` is in your PATH (automatically added by the installer)
- **Permission issues?** The installer is rootless and installs everything to `~/.local` and `~/.myprofile`

## Requirements

- Git must be installed
- Internet connection for downloading tools
- Bash shell (Linux/macOS) or PowerShell (Windows)

## License

This project is provided as-is for personal development environment setup.