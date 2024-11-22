#!/bin/bash
set -eu

CWD=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
bash_profile=$CWD/../bash_profile
vimrcs=$CWD/../vimrcs
config=$CWD/../config
utility=$CWD/../utility
tmuxconfig=$HOME/.tmux.conf
bashrc=$HOME/.bashrc
profile=$HOME/.bash_profile
vimrc=$HOME/.vimrc
gitconfig=$HOME/.gitconfig
sshconfig=$HOME/.ssh/config
local_dir=$HOME/.local
local_bin=$local_dir/bin
mkdir -p $local_bin
git_clone='git clone -q --depth=1 '

check_command() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

curl_install() {
    if [ $# == 1 ];then
        curl $1 -fsSL | bash
    elif (( $# > 1 ));then
        local url=$1
        shift
        curl $url -fsSL | bash -s -- $*
    fi
}

work_in_temp_dir() {
    # DON'T set tempdir to local variable!
    tempdir=$(mktemp -d)
    cd $tempdir
    trap 'rm -rf $tempdir' EXIT
}

latest_in_github_release() {
    local latest_version=$(basename `curl -w "%{redirect_url}" -s $1`)
    printf "$latest_version"
}

ask_exit() {
    read -rp "[?] Re-login for the profile to take effect (y/n)? " answer
    case ${answer:0:1} in
        y|Y )
            pkill -KILL -u $USER
            ;;
        * )
            echo "[*] Aborting..."
            ;;
    esac
}

download() {
    local url=$1
    local location=${2:-}
    local opts='-O'
    [ -n "$location" ] && opts="-o $location"
    curl -sL $opts $url
}

is_win() {
    uname -a | grep -i MINGW >/dev/null 2>&1
}
