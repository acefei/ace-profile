#!/bin/bash

source $HOME/.ace_profile_env

INSTALLATION_PATH=$PROFILE_PATH/installer
source $INSTALLATION_PATH/precondition.sh

trap teardown EXIT
teardown() {
    echo
    echo "Installation complete! To run 'bash' for the updated profile to take effect."
}

setup_git() {
    # refer to https://apple.stackexchange.com/a/328144
    git_ver=$(git --version | awk '{print $3}')
    download $HOME/.git-completion.bash https://raw.github.com/git/git/v$git_ver/contrib/completion/git-completion.bash 
    download $HOME/.git-prompt.sh https://raw.githubusercontent.com/git/git/v$git_ver/contrib/completion/git-prompt.sh 
    download $HOME/.git-flow-completion.bash https://raw.githubusercontent.com/bobthecow/git-flow-completion/master/git-flow-completion.bash

    [ -e $gitconfig ] && mv ${gitconfig}{,.backup}
    ln -sf $config/_gitconfig $gitconfig

    echo ">>>>>  Add git config successfully..."
}

setup_bash_profile() {
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

setup_vimrc() {
    [ -e $vimrc ] && mv ${vimrc}{,.backup}
    [ -e $ideavimrc ] && mv ${ideavimrc}{,.backup}
    ln -sf $vimrcs/_vimrc_without_plug $vimrc
    ln -sf $vimrcs/_ideavimrc $ideavimrc

    echo ">>>>>  Add vimrc successfully..."
}

setup_pyenv() {
    curl_install https://pyenv.run
    pyenvrc=~/.pyenvrc
    tee $pyenvrc <<-'EOF'
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
    echo "source $pyenvrc" >> $profile
}

main() {
    set -e
    setup_git
    setup_bash_profile
    setup_vimrc
    config_ssh
    setup_fzf
    setup_fpp
    setup_pyenv
}

##################### MAIN ##########################
main
echo ">>> Will enter stage two in 5 sec, you might COMPLETE installation right now by CTRL+C"
sleep 5
exec $INSTALLATION_PATH/stage2.sh
