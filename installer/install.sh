#!/bin/bash

if [ ! -x $(command -v git) ]; then
    echo "please install git first."
    exit 1
fi

echo "PROFILE_PATH=$HOME/.myprofile" > $HOME/.ace_profile_env
source $HOME/.ace_profile_env

if [ -d "$PROFILE_PATH" ];then
    echo  "Please remove $PROFILE_PATH and try again!"
    exit 1 
fi

git clone -q https://github.com/acefei/ace-profile.git $PROFILE_PATH

$PROFILE_PATH/installer/rootless_install.sh
