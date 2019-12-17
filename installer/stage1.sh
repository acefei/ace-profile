#!/bin/bash

source $HOME/.ace_profile_env

INSTALLATION_PATH=$PROFILE_PATH/installer
source $INSTALLATION_PATH/provision.sh

trap teardown EXIT
teardown() {
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

    echo ">>>>>  Add git config successfully..."
}

config_profile() {
    echo > $profile
    for f in $bash_profile/_*
    do
        echo "source $f in $profile"
        echo "source $f" >> $profile
    done

    tee -a $profile <<-'EOF'
export PATH=$PATH:~/.local/bin
EOF

    [ -e $bashrc ] && mv ${bashrc}{,.backup}
    ln -sf $profile $bashrc

    echo ">>>>>  Add bash profile successfully..."
}

config_ssh() {
    [ -d $HOME/.ssh ] || mkdir $HOME/.ssh
    ln -sf $config/ssh_config $sshconfig

    # fix Bad owner or permissions on XXX
    chmod 600 $sshconfig

    echo ">>>>>  Add config in $HOME/.ssh successfully..."
}

setup_fzf() {
    $git_clone https://github.com/junegunn/fzf.git ~/.fzf
    yes | ~/.fzf/install

    fzfrc=~/.fzfrc
    tee $fzfrc <<-'EOF'
export FZF_FIND_PATH=$HOME
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
alias vigo='vi $(find $FZF_FIND_PATH -type f | fzf)'
alias cdgo='cd $(find $FZF_FIND_PATH -type d | fzf)'
EOF
    echo "source $fzfrc" >> $profile
    echo ">>>>>  Setup fzf successfully..."
}

setup_fpp() {
    $git_clone https://github.com/facebook/PathPicker.git  ~/.PathPicker
    ln -sf ~/.PathPicker/fpp $local_bin/fpp
    echo ">>>>>  Setup fpp successfully..."
}

config_vimrc() {
    [ -e $vimrc ] && mv ${vimrc}{,.backup}
    ln -sf $vimrcs/_vimrc_without_plug $vimrc
    echo "export EDITOR=vi" >> $profile
    echo ">>>>>  Add vimrc successfully..."
}

config_tmux() {
    [ -e $tmuxconfig ] && mv ${tmuxconfig}{,.backup}
    ln -sf $config/tmux.conf $tmuxconfig
    echo ">>>>>  Add tmux config successfully..."
}

main() {
    config_profile
    config_git
    config_vimrc
    config_ssh
    config_tmux
    setup_fzf
    setup_fpp
}

##################### MAIN ##########################
main
#echo ">>> Will enter stage two in 5 sec, you might COMPLETE installation right now by CTRL+C"
#sleep 5
#exec $INSTALLATION_PATH/stage2.sh
