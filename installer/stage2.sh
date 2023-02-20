#!/bin/bash
set -euo pipefail

setup=$(mktemp -dt "$(basename "$0").XXXXXXXXXX")

# Only print error log on errexit
errlog=/tmp/install_err.log
exec 3>&2
_teardown(){
    local exit_code=$?
    exec 2>&3
    rm -rf "$setup"
    if [ $exit_code -eq 0 ];then
        echo
        echo "Installation complete!"
        ask_exit
    else
        cat $errlog >&2
        rm -rf $errlog
        exit $exit_code
    fi
}
trap _teardown EXIT 

current_dir=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
source $current_dir/provision.sh

build-essential() {
    install['yum']="epel-release gcc nfs-utils automake autoconf libtool make git-lfs"
    install['apt']="build-essential automake nfs-common git-lfs \
        libbz2-dev \
        libc6-dev \
        libexpat1-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev"
    install_pack ${install["$pm"]}
}

vim8() {
    install['apt']='vim-nox'
    install['yum']='vim-enhanced'
    install_pack ${install["$pm"]}

    #install vim plugin
    $utility/vim_pack &
}

tmux(){
    install['apt']='tmux'
    install['yum']='tmux'
    install_pack ${install["$pm"]}
}

fd-find() {
    install['apt']='nodejs'
    install['yum']='nodejs'
    install_pack ${install["$pm"]}
    $gosu npm install -g fd-find --unsafe
}

_main() {
    echo "Start installing checked options..."
    local func_list=$(install_functions)
    source $current_dir/multiselect $func_list 

    # Move code here as the output from `read -p` would be sent to fd 2
    exec 2>$errlog

    local func
    for func in ${CHECKED_OPTIONS[@]} ;do
        echo "---> Installing $func."
        $func >/dev/null
        echo "---> Install $func done."
    done
}

_main
