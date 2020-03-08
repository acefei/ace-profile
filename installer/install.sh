#!/bin/bash

if [ ! -x $(command -v git) ]; then
    echo "please install git first."
    exit 1
fi

echo "PROFILE_PATH=$HOME/.myprofile" > $HOME/.ace_profile_env
source $HOME/.ace_profile_env

git clone -q https://github.com/acefei/ace-profile.git $PROFILE_PATH
$PROFILE_PATH/installer/stage1.sh
