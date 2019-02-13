#!/bin/sh

if ! which git > /dev/null 2>&1; then
    echo "please install git first."
    exit -1
fi

tee $HOME/.ace_profile_env <<EOF
PROFILE_PATH=$HOME/.myprofile
EOF
. $HOME/.ace_profile_env
git clone --depth=1 https://github.com/acefei/ace-profile.git $PROFILE_PATH
$PROFILE_PATH/installer/genesis.sh
