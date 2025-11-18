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
    fi
    return 1
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
    curl -sSL $opts $url
}

is_win() {
    uname -a | grep -i MINGW >/dev/null 2>&1
}

is_mac() {
    [[ "$OSTYPE" == "darwin"* ]] || uname -s | grep -i Darwin >/dev/null 2>&1
}

extract() {
    local file=$1
    local dest=${2:-.}
    
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found" >&2
        return 1
    fi
    
    case "$file" in
        *.tar.gz|*.tgz)
            tar -xzf "$file" -C "$dest"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$file" -C "$dest"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$file" -C "$dest"
            ;;
        *.tar)
            tar -xf "$file" -C "$dest"
            ;;
        *.gz)
            gunzip -c "$file" > "$dest/$(basename "$file" .gz)"
            ;;
        *.bz2)
            bunzip2 -c "$file" > "$dest/$(basename "$file" .bz2)"
            ;;
        *.xz)
            unxz -c "$file" > "$dest/$(basename "$file" .xz)"
            ;;
        *.zip)
            unzip -q "$file" -d "$dest"
            ;;
        *)
            echo "Error: Unsupported archive format: $file" >&2
            return 1
            ;;
    esac
}

install_with_spinner() {
    local name=$1
    local func=$2
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local i=0
    
    $func &> /dev/null &
    local pid=$!
    
    while ps -p $pid > /dev/null 2>&1; do
        i=$(((i+1) % 8))
        printf "\r  ${spin:$i:1} %s" "$name"
        sleep 0.1
    done
    
    if wait $pid; then
        printf "\r\033[K  ✓ %s\n" "$name"
    else
        printf "\r\033[K  ✗ %s --> rerun: $0 %s\n" "$name" "$name" >&2
        return 1
    fi
}

safe_remove() {
    local path=$1
    local desc=$2
    if [ -e "$path" ]; then
        echo "  Removing $desc..."
        rm -rf "$path"
    fi
}

restore_backup() {
    local file=$1
    if [ -e "${file}.backup" ]; then
        echo "  Restoring ${file} from backup..."
        mv "${file}.backup" "$file"
    fi
}
