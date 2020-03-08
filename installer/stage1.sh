#!/bin/bash

source $HOME/.ace_profile_env

INSTALLATION_PATH=$PROFILE_PATH/installer
source $INSTALLATION_PATH/provision.sh

trap _teardown EXIT
_teardown() {
    echo
    echo "Installation complete! To run 'bash' for the updated profile to take effect."
}

config_git() {
    # refer to https://apple.stackexchange.com/a/328144
    git_ver=$(git --version | awk '{print $3}')
    download $HOME/.git-completion.bash https://raw.github.com/git/git/v$git_ver/contrib/completion/git-completion.bash 
    download $HOME/.git-prompt.sh https://raw.githubusercontent.com/git/git/v$git_ver/contrib/completion/git-prompt.sh 
    download $HOME/.git-flow-completion.bash https://raw.githubusercontent.com/bobthecow/git-flow-completion/master/git-flow-completion.bash

    [ -e $gitconfig ] && mv ${gitconfig}{,.backup}
    ln -sf $config/_gitconfig $gitconfig
}

config_profile() {
    echo > $profile
    tee -a $profile >/dev/null <<-'EOF'

# Disable flow control for that terminal completely
# To free the shortcuts Ctrl+s and Ctrl+q
stty -ixon

# local bin
export PATH=$PATH:~/.local/bin

# default EDITOR
export EDITOR=vi

# fzf
[ -f ~/.fzfrc ] && source ~/.fzfrc

EOF

    local pf
    for pf in $bash_profile/_* ;do
        echo "source $pf" >> $profile
    done

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
    ln -sf $config/ssh_config $sshconfig

    # fix Bad owner or permissions on XXX
    chmod 600 $sshconfig
}

setup_fzf() {
    $git_clone https://github.com/junegunn/fzf.git ~/.fzf 

    yes | ~/.fzf/install > /dev/null

    tee ~/.fzfrc >/dev/null <<-'EOF'
export FZF_FIND_PATH=$HOME
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

alias vigo='vi $(find $FZF_FIND_PATH -type f | fzf)'
alias cdgo='cd $(find $FZF_FIND_PATH -type d | fzf)'
EOF
}

setup_fpp() {
    $git_clone https://github.com/facebook/PathPicker.git  ~/.PathPicker
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

_main() {
    local func_list=$(install_functions)
    local func
    for func in $func_list; do
        {
            eval ${func} 
            echo "---> $func done..."

        } &
    done
    wait
}

##################### MAIN ##########################
_main

# continue stage2 with sudo priviledge.
exec $INSTALLATION_PATH/stage2.sh
