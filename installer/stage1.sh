#!/bin/bash

source $HOME/.ace_profile_env

INSTALLATION_PATH=$PROFILE_PATH/installer
source $INSTALLATION_PATH/provision.sh

trap _teardown EXIT
_teardown() {
    local exit_code=$?
    if [ $exit_code -eq 0 ];then
		echo
		echo "Installation complete! To run 'bash' for the updated profile to take effect."
    else
        exit $exit_code
    fi

}

config_git() {
    # refer to https://apple.stackexchange.com/a/328144
    git_ver=$(git --version | awk '{print $3}')
    git_url=https://raw.githubusercontent.com/git/git
    [ -n "$USE_GITEE" ] && git_url=https://gitee.com/mirrorgit/git/raw
    download $git_url/v$git_ver/contrib/completion/git-completion.bash $HOME/.git-completion.bash
    download $git_url/v$git_ver/contrib/completion/git-prompt.sh $HOME/.git-prompt.sh

    [ -e $gitconfig ] && mv ${gitconfig}{,.backup}
    ln -sf $config/_gitconfig $gitconfig
}

config_profile() {
    echo > $profile
    tee -a $profile >/dev/null <<-'EOF'

# Disable flow control for that terminal completely
# To free the shortcuts Ctrl+s and Ctrl+q
# stty -ixon

# history
export HISTSIZE=100
export HISTFILESIZE=100

# local bin
export PATH=$PATH:~/.local/bin:~/.local/miniconda/bin

# default EDITOR
export EDITOR=vi

# fzf
[ -f ~/.fzfrc ] && source ~/.fzfrc
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

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
    [ -d $HOME/.ssh ] || mkdir $HOME/.ssh
    cp -f $config/ssh_config $sshconfig

    # fix Bad owner or permissions on XXX
    chmod 600 $sshconfig
}

setup_fzf() {
    git_url=https://github.com/junegunn/fzf.git
    [ -n "$USE_GITEE" ] && git_url=https://gitee.com/open-resource/fzf.git
    $git_clone $git_url ~/.fzf

    yes | ~/.fzf/install > /dev/null


    tee -a ~/.fzf.bash >/dev/null <<-'EOF'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

if command -v fd > /dev/null ; then
	export FZF_DEFAULT_COMMAND="fd --hidden --exclude .git . $HOME"
	export FZF_ALT_C_COMMAND="${FZF_DEFAULT_COMMAND} --type directory"
else
	export FZF_DEFAULT_COMMAND="find $HOME ! -path '*/.git/*'"
	export FZF_ALT_C_COMMAND="${FZF_DEFAULT_COMMAND} -type d"
fi
EOF
}

setup_pyenv() (
    work_in_temp
    curl https://pyenv.run | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> $bashrc
    echo 'eval "$(pyenv init -)"' >> $bashrc
)

setup_shellcheck() (
    work_in_temp
    download https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.$(arch).tar.xz
    tar xvf shellcheck*.tar.xz
    install shellcheck*/shellcheck $local_bin
)

setup_sops() (
    work_in_temp
    ver=$(latest_in_github_release "https://github.com/mozilla/sops/releases/latest")
    download https://github.com/mozilla/sops/releases/download/$ver/sops-$ver.linux.amd64
    install sops-* $local_bin/sops
)

setup_age() (
    work_in_temp
    ver=$(latest_in_github_release "https://github.com/FiloSottile/age/releases/latest")
    download https://github.com/FiloSottile/age/releases/download/$ver/age-$ver-linux-amd64.tar.gz
    tar zxvf age*.tar.gz
    install -D age/age* $local_bin
)

setup_fpp() {
    git_url=https://github.com/facebook/PathPicker.git
    [ -n "$USE_GITEE" ] && git_url=https://gitee.com/mirrors/PathPicker.git
    $git_clone $git_url ~/.PathPicker
    ln -sf ~/.PathPicker/fpp $local_bin/fpp
}

config_vimrc() {
    [ -e $vimrc ] && mv ${vimrc}{,.backup}
    ln -sf $vimrcs/_vimrc_without_plug $vimrc
}

config_tmux() {
    [ -e $tmuxconfig ] && mv ${tmuxconfig}{,.backup}
    ln -sf $config/tmux.conf $tmuxconfig
}

_set_mirror() {
    [ -z "$USE_GITEE" ] && return
    export SET_MIRROR=yes
    $utility/deploy_mirror ||:
}

_main() {
    local func_list=$(install_functions)
    local func
    for func in $func_list; do
        {
            echo "---> start $func..."
            ${func}
            echo "---> $func done..."

        } &
    done
    wait
}

##################### MAIN ##########################
if [ -z "${1:-}" ];then
    _main
    # continue stage2 with sudo priviledge.
    _set_mirror
    exec $INSTALLATION_PATH/stage2.sh
else
    # test specific setup method.
    eval "$1"
fi
