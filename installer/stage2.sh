#!/bin/bash
set -eu

setup=$(mktemp -dt "$(basename "$0").XXXXXXXXXX")
_teardown(){
    local exit_code=$?
    rm -rf "$setup"
    if [ $exit_code -eq 0 ];then
        echo
        echo "Installation complete!"
        ask_exit
    else
        exit $exit_code
    fi
}
trap _teardown EXIT

current_dir=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
source $current_dir/provision.sh

build-essential() {
    install['yum']="epel-release gcc automake autoconf libtool make git-lfs"
    install['apt']="build-essential automake nfs-common git-lfs"
    install_pack ${install["$pm"]}
}

vim8() {
    install['apt']='vim-nox'
    install['yum']='vim-enhanced'
    install_pack ${install["$pm"]}

    #install vim plugin
    $utility/vim_pack
}

tmux(){
    install['apt']='tmux'
    install['yum']='tmux'
    install_pack ${install["$pm"]}
}

qemu-kvm() {
    if cat /proc/cpuinfo | egrep "vmx|svm";then
        echo "Not Support Virtualization"
        return
    fi

    install['apt']='bridge-utils virtinst'
    install['yum']=''
    install_pack ${install["$pm"]}
}

shellcheck() {
    install['apt']='shellcheck'
    install['yum']='ShellCheck'
    install_pack ${install["$pm"]}
}


_main() {
    echo "Start installing checked options..."
    local func_list=$(install_functions)
    source $current_dir/multiselect $func_list 

    local func
    for func in ${CHECKED_OPTIONS[@]} ;do
        eval "$func >/dev/null 2>.install.err"
        echo "---> Install $func successfully."
    done
}

_main
