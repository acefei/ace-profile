#!/bin/bash

gosu=''
if [ `id -u` -ne 0 ];then  
    gosu=' sudo '
fi  

git_clone='git clone --depth=1 '

CWD=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
bash_profile=$CWD/../bash_profile
vimrcs=$CWD/../vimrcs
config=$CWD/../config

tmuxconfig=$HOME/.tmux.conf
bashrc=$HOME/.bashrc
profile=$HOME/.bash_profile
vimrc=$HOME/.vimrc
ideavimrc=$HOME/.ideavimrc
gitconfig=$HOME/.gitconfig
sshconfig=$HOME/.ssh/config

local_dir=$HOME/.local
local_bin=$local_dir/bin
mkdir -p $local_bin

# define package name for the different distro 
declare -A install

# get the number of CPU cores for build
if [ -f /proc/cpuinfo  ]; then
    CPUS=`grep processor /proc/cpuinfo | wc -l`
else
    CPUS=2
fi

get_from_github () {
    local pack_name=''
    if [[ "$pack_name" =~ "/" ]];then
        pack_name=$1
    else
        pack_name=$1/$1
    fi

    if type "git" &> /dev/null ; then
        $git_clone https://github.com/$pack_name
    else
        curl -L https://github.com/$pack_name/archive/master.tar.gz -o ${pack_name##*/}.tar.gz
        tar xvzf ${pack_name##*/}.tar.gz
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

download() {
    local location=$1
    local url=$2

    set -e
    if which curl > /dev/null 2>&1; then
        curl -sL -o $location $url
    elif which wget > /dev/null 2>&1; then
        wget -q -O $location $url
    else
        echo "please install curl/wget firstly."
        exit -1
    fi
    set +e
}

distro_identify() {
    release_file=/etc/os-release
    if [ -e $release_file ]; then
        source $release_file && echo $ID
    fi
}

pmu_identify() {
    # find out the Package Management Utility
    if [ -e /usr/bin/yum ]; then
        distro='yum'
    elif [ -e /usr/bin/apt ]; then
        distro='apt'
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi
}

install_pack() {
    local pack_name="$*"
    echo "===> Start to install $pack_name"
    set -e
    if [ -e /usr/bin/yum ]; then
        $gosu yum install -y $pack_name
    elif [ -e /usr/bin/apt ]; then
        $gosu apt install -y $pack_name
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi
    set +e
}

remove_pack() {
    local pack_name="$*"
    echo "===> Start to remove $pack_name"
    set -e
    if [ -e /usr/bin/yum ]; then
        $gosu yum remove -y $pack_name
    elif [ -e /usr/bin/apt ]; then
        echo "$gosu apt remove -y $pack_name"
        $gosu apt autoremove -y $pack_name
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi
    set +e
}

sudo_check() {
    if [ `id -u` -ne 0 ]; then
        echo "Error: please execute this script with sudo privilege."
        exit -1
    fi

    USER_HOME=$(eval "cd ~$SUDO_USER; pwd")
}

pmu_identify
