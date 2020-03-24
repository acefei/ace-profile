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
    install['yum']="epel-release gcc automake autoconf libtool make git-lfs"
    install['apt']="build-essential automake nfs-common git-lfs"
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
    install['apt']='fd-find'
    install['yum']='fd-find'
    install_pack ${install["$pm"]}
    echo "alias fd=fdfind" >> $HOME/.fzf.bash
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

nodejs-lts() {
    local nodesource_list=/etc/apt/sources.list.d/nodesource.list
    if [ ! -f "$nodesource_list" ];then
        if [ "$pm" == "yum" ]; then
            curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -
        elif [ "$pm" == "apt" ]; then
            curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
            [ -n "$SET_MIRROR" ] && sudo perl -pi -e "s#https://deb.nodesource.com/#http://mirrors.ustc.edu.cn/nodesource/deb/#g" $nodesource_list
        fi
    fi

    install['apt']='nodejs'
    install['yum']='nodejs'
    install_pack ${install["$pm"]}
}

vscode() {
    # Pre-install for vscode common issue 
    # https://code.visualstudio.com/docs/setup/linux#_common-questions
    install['apt']="gvfs-bin"
    install['yum']=""
    install_pack ${install["$pm"]}
    
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

    # VSCODE installation
    if [ "$pm" == "yum" ]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    elif [ "$pm" == "apt" ]; then
        wget -O $setup/vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868
    fi

    install['apt']="$setup/vscode.deb"
    install['yum']="code"
    install_pack ${install["$pm"]}
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
