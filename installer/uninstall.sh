#!/bin/bash

source $HOME/.ace_profile_env
INSTALLATION_PATH=$PROFILE_PATH/installer
source $INSTALLATION_PATH/global.sh

echo "========================================"
echo "  Ace Profile Uninstaller"
echo "========================================"
echo ""

# Confirmation prompt
read -p "This will remove ace-profile configuration and installed tools. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo "Starting uninstallation..."
echo ""

# Remove ~/.local/
safe_remove "$HOME/.local/" "local directory"

# Remove vim plugins
safe_remove "$HOME/.vim/pack" "Vim plugins"

# Remove configuration directories
safe_remove "$HOME/.fzf" "fzf"
safe_remove "$HOME/.fzf.bash" "fzf bash config"
safe_remove "$HOME/.fzfrc" "fzf config"
safe_remove "$HOME/.PathPicker" "PathPicker"
safe_remove "$HOME/.nvm" "NVM"

# Remove git completion files
safe_remove "$HOME/.git-completion.bash" "Git completion"
safe_remove "$HOME/.git-prompt.sh" "Git prompt"

# Restore backed up files
restore_backup "$HOME/.bashrc"
restore_backup "$HOME/.bash_profile"
restore_backup "$HOME/.vimrc"
restore_backup "$HOME/.gitconfig"
restore_backup "$HOME/.tmux.conf"

# Remove symlinks if they point to non-existent locations
for file in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.vimrc" "$HOME/.gitconfig" "$HOME/.tmux.conf"; do
    if [ -L "$file" ] && [ ! -e "$file" ]; then
        echo "  Removing broken symlink: $file"
        rm -f "$file"
    fi
done

# Remove environment file
safe_remove "$HOME/.ace_profile_env" "environment file"

# Change to home directory before removing profile directory
cd "$HOME"

# Remove profile directory (must be last)
safe_remove "$HOME/.myprofile" "ace-profile directory"

echo ""
echo "========================================"
echo "  Uninstallation Complete!"
echo "========================================"
echo ""
echo "The following items were removed:"
echo "  - ~/.myprofile directory"
echo "  - Installed tools from ~/.local/"
echo "  - Configuration files and symlinks"
echo "  - Vim plugins"
echo ""
echo "Backed up files (if any) have been restored."
echo "Please restart your shell or re-login for changes to take effect."
echo ""
