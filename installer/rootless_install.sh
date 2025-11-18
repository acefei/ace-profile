#!/bin/bash

source $HOME/.ace_profile_env

INSTALLATION_PATH=$PROFILE_PATH/installer
source $INSTALLATION_PATH/global.sh

trap teardown EXIT
teardown() {
    local exit_code=$?
    if [ $exit_code -eq 0 ];then
        echo "Installation Successfully!"
        is_win && return
        ask_exit
    else
        exit $exit_code
    fi

}

config_git() {
    git_ver=$(git --version | cut -d' ' -f3 | cut -d'.' -f1-3)
    git_url=https://raw.githubusercontent.com/git/git
    download $git_url/v$git_ver/contrib/completion/git-completion.bash $HOME/.git-completion.bash
    download $git_url/v$git_ver/contrib/completion/git-prompt.sh $HOME/.git-prompt.sh

    [ -e $gitconfig ] && mv ${gitconfig}{,.backup}
    ln -sf $config/_gitconfig $gitconfig
}

config_profile() {
    echo > $profile
    tee -a $profile >/dev/null <<-'EOF'
# To free the shortcuts Ctrl+s and Ctrl+q
stty start undef

# history
export HISTSIZE=100
export HISTFILESIZE=100

# locale
export LC_ALL=en_US.UTF-8

# local bin
export PATH=~/.local/bin:~/.local/go/bin:$PATH

# default EDITOR
export EDITOR=vi

# fzf
[ -f ~/.fzfrc ] && source ~/.fzfrc
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion"  ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

EOF

    echo "source $bash_profile/dynamic_source_all" >> $profile

    [ -e $bashrc ] && mv ${bashrc}{,.backup}
    ln -sf $profile $bashrc
}

config_utility() {
    cd $local_bin
    for cmd in $(cd $PROFILE_PATH/utility/ && echo *)
    do
        ln -sf  $PROFILE_PATH/utility/$cmd $cmd
    done
}

config_ssh() {
    $PROFILE_PATH/vimrcs/vim_plug_installer
}

config_tmux() {
    { is_win || is_mac; } && return
    [ -e $tmuxconfig ] && mv ${tmuxconfig}{,.backup}
    ln -sf $config/tmux.conf $tmuxconfig
}

setup_gitui() {
    { is_win || is_mac; } && return
    work_in_temp_dir
    local name="gitui-org/gitui"
    local ver=$(latest_in_github_release "https://github.com/$name/releases/latest")
    download https://github.com/$name/releases/download/$ver/gitui-linux-x86_64.tar.gz
    extract gitui-linux-x86_64.tar.gz
    install gitui $local_bin/
}

setup_rg() {
    { is_win || is_mac; } && return
    work_in_temp_dir
    local name="BurntSushi/ripgrep"
    local ver=$(latest_in_github_release "https://github.com/$name/releases/latest")
    download https://github.com/$name/releases/download/$ver/ripgrep-$ver-x86_64-unknown-linux-musl.tar.gz
    extract ripgrep*.tar.gz
    install ripgrep-*/rg $local_bin/
}

setup_gh() {
    { is_win || is_mac; } && return
    work_in_temp_dir
    local name="cli/cli"
    local ver=$(latest_in_github_release "https://github.com/$name/releases/latest")
    download https://github.com/$name/releases/download/$ver/gh_${ver##v}_linux_amd64.tar.gz
    extract gh_${ver##v}_linux_amd64.tar.gz
    install gh_${ver##v}_linux_amd64/bin/gh $local_bin/
}

setup_fzf() {
    git_url=https://github.com/junegunn/fzf.git
    local dest_path=$HOME/.fzf
    [ -d $dest_path ] && return
    $git_clone $git_url $dest_path
    yes | $dest_path/install > /dev/null
    tee -a $HOME/.fzf.bash >/dev/null <<-'EOF'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

if command -v rg > /dev/null ; then
    export FZF_DEFAULT_COMMAND='rg --hidden --files --follow --glob "!{.git,node_modules}/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --null 2>/dev/null | xargs -0 dirname | awk '!h[\$0]++'"
else
    export FZF_DEFAULT_COMMAND="find $HOME ! -path '*/.git/*'"
    export FZF_ALT_C_COMMAND="${FZF_DEFAULT_COMMAND} -type d"
fi

bind -x '"\C-p": vim $(fzf);'
EOF
}

setup_uv() (
    is_win && return
    work_in_temp_dir
    curl_install https://astral.sh/uv/install.sh
)

setup_nvm() (
    is_win && return
    work_in_temp_dir
    local ver=$(latest_in_github_release "https://github.com/nvm-sh/nvm/releases/latest")
    curl_install https://raw.githubusercontent.com/nvm-sh/nvm/${ver}/install.sh
)

setup_go() (
    { is_win || is_mac; } && return
    work_in_temp_dir
    local ver=1.22.2
    download https://dl.google.com/go/go${ver}.linux-amd64.tar.gz
    rm -rf $HOME/.local/go
    extract go${ver}.linux-amd64.tar.gz $HOME/.local
)

setup_terraform() (
    { is_win || is_mac; } && return
    work_in_temp_dir
    local ver=1.8.2
    curl -O https://releases.hashicorp.com/terraform/${ver}/terraform_${ver}_linux_amd64.zip
    extract terraform_${ver}_linux_amd64.zip
    install terraform $local_bin
)

setup_sops() (
    { is_win || is_mac; } && return
    work_in_temp_dir
    local ver=$(latest_in_github_release "https://github.com/mozilla/sops/releases/latest")
    download https://github.com/mozilla/sops/releases/download/$ver/sops-$ver.linux.amd64
    install sops-* $local_bin/sops
)

setup_age() (
    { is_win || is_mac; } && return
    work_in_temp_dir
    local ver=$(latest_in_github_release "https://github.com/FiloSottile/age/releases/latest")
    download https://github.com/FiloSottile/age/releases/download/$ver/age-$ver-linux-amd64.tar.gz
    extract age*.tar.gz
    install -D age/age* $local_bin
)

setup_fpp() (
    local git_url=https://github.com/facebook/PathPicker.git
    local dest_path=$HOME/.PathPicker
    [ ! -d $dest_path ] && $git_clone $git_url $dest_path
    ln -sf $dest_path/fpp $local_bin/fpp
)


_main() {
    # Run config functions first (sequentially)
    local config_functions=$(declare -F | cut -d' ' -f3 | grep "config_")
    for func in $config_functions; do
        echo "---> Running $func..."
        ${func}
    done
    
    echo ""
    echo "Installing packages concurrently..."
    
    # Run setup functions with spinner (concurrently)
    local setup_functions=$(declare -F | cut -d' ' -f3 | grep "setup_")
    for func in $setup_functions; do
        install_with_spinner "$func" "$func" &
    done
    wait
}

##################### MAIN ##########################
if [ -z "${1:-}" ];then
    _main
else
    # test specific setup method.
    set -x
    eval "$1"
fi
