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
git_clone='git clone -q --depth=1 '

# define package name for the different distro 
declare -A install
mkdir -p $local_bin

gosu=''
if [ `id -u` -ne 0 ];then  
    gosu=' sudo '
fi  

# get the number of CPU cores for build
CPUS=2
if [ -f /proc/cpuinfo  ]; then
    CPUS=`grep processor /proc/cpuinfo | wc -l`
fi

# Operating system identification
source /etc/os-release
case "${ID_LIKE:-${ID:-unknown}}" in
  rhel*|centos)
      pm=yum
      ;;
  debian*)
      export DEBIAN_FRONTEND=noninteractive
      pm=apt
      ;;
  *)
      echo Unknown OS, currently only support centos/debian.
      exit 1
      ;;
esac

install_pack() {
    local pack_name="$*"
    if [ -z "$pack_name" ];then 
        echo "no package need to install"
        return 
    fi
    echo "Installing $pack_name"
    $gosu $pm install -y $pack_name
}

remove_pack() {
    local pack_name="$*"
    echo "Removing $pack_name"
    $gosu $pm remove -y $pack_name
}

get_from_github () {
    local pack_name=''
    if [[ "$pack_name" =~ "/" ]];then
        pack_name=$1
    else
        pack_name=$1/$1
    fi

    echo "Git clone $pack_name"

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
    local url=$1
    local location=${2:-}
    local opts=''

    if [ -x "$(command -v curl)" ];then
        opts='-O'
        [ -n "$location" ] && opts="-o $location"
        curl -sL $opts $url
    elif [ -x "$(command -v wget)" ]; then
        [ -n "$location" ] && opts="-O $location"
        wget -q $opts $url
    else
        echo "Please install curl/wget firstly."
        exit 1
    fi
}

sudo_check() {
    if [ `id -u` -ne 0 ]; then
        echo "Error: please execute this script with sudo privilege."
        exit 1
    fi

    export USER_HOME=$(eval "cd ~$SUDO_USER; pwd")
}

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

work_in_temp() {
    d=$(mktemp -d)
    cd $d
    trap 'rm -rf $d' EXIT
}

install_functions() {
    grep -Po "^[^_][\w-]+(?=\(\))" $0
}

latest_in_github_release() {
    local latest_version=$(basename `curl -w "%{redirect_url}" -s $1`)
    echo "$latest_version"
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
