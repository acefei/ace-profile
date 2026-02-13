#!/bin/bash

REPO="acefei/ace-profile"
BRANCH="main"

echo "PROFILE_PATH=$HOME/.myprofile" > $HOME/.ace_profile_env
source $HOME/.ace_profile_env

if [ -d "$PROFILE_PATH" ];then
    echo  "Please remove $PROFILE_PATH and try again!"
    exit 1 
fi

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$HOME"
    mv "$HOME/ace-profile-$BRANCH" "$PROFILE_PATH"
elif command -v wget >/dev/null 2>&1; then
    wget -qO- "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$HOME"
    mv "$HOME/ace-profile-$BRANCH" "$PROFILE_PATH"
elif command -v git >/dev/null 2>&1; then
    git clone -q "https://github.com/$REPO.git" "$PROFILE_PATH"
else
    echo "Error: curl, wget, or git is required to install."
    exit 1
fi

$PROFILE_PATH/installer/rootless_install.sh
