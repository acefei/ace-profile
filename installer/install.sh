#!/bin/bash

repo_host=${1:-github}

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

git clone -q https://${repo_host}.com/acefei/ace-profile.git $PROFILE_PATH

USE_GITEE=''
if [ "$repo_host" != "github" ];then
    USE_GITEE=yes
fi
export USE_GITEE
$PROFILE_PATH/installer/rootless_install.sh
