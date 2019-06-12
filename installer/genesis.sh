#!/bin/bash

source $HOME/.ace_profile_env

INSTALLATION_PATH=$PROFILE_PATH/installer
source $INSTALLATION_PATH/precondition.sh

setup_git()
{
    # refer to https://apple.stackexchange.com/a/328144
    git_ver=$(git --version | awk '{print $3}')
    download $HOME/.git-completion.bash https://raw.github.com/git/git/v$git_ver/contrib/completion/git-completion.bash 
    download $HOME/.git-prompt.sh https://raw.githubusercontent.com/git/git/v$git_ver/contrib/completion/git-prompt.sh 
    download $HOME/.git-flow-completion.bash https://raw.githubusercontent.com/bobthecow/git-flow-completion/master/git-flow-completion.bash

    [ -e $gitconfig ] && mv ${gitconfig}{,.backup}
    ln -sf $config/_gitconfig $gitconfig

    echo ">>>>>  Add git config successfully..."
}

setup_bash_profile()
{
    echo > $profile
    for f in $bash_profile/_*
    do
        echo "source $f in $profile"
        echo "source $f" >> $profile
    done


    tee -a $profile <<-'EOF'
export PATH=$PATH:~/.local/bin
eval "$(ssh-agent)"
ssh-add
EOF

    [ -e $bashrc ] && mv ${bashrc}{,.backup}
    ln -sf $profile $bashrc

    echo ">>>>>  Add bash profile successfully..."
}

config_ssh() {
    [ -d $HOME/.ssh ] || mkdir $HOME/.ssh
    ln -sf $config/ssh_config $sshconfig

    echo ">>>>>  add config in $HOME/.ssh successfully..."
}

setup_fzf()
{
    $git_clone https://github.com/junegunn/fzf.git ~/.fzf
    yes | ~/.fzf/install

    echo ">>>>>  Setup fzf successfully..."
}

setup_fpp()
{
    $git_clone https://github.com/facebook/PathPicker.git  ~/.PathPicker
    ln -sf ~/.PathPicker/fpp $local_bin/fpp
    echo ">>>>>  Setup fpp successfully..."
}


setup_vimrc()
{
    [ -e $vimrc -o -h $vimrc ] && mv ${vimrc}{,.backup}
    [ -e $ideavimrc -o -h $ideavimrc ] && mv ${ideavimrc}{,.backup}
    ln -s $vimrcs/_vimrc_without_plug $vimrc
    ln -s $vimrcs/_ideavimrc $ideavimrc

    echo ">>>>>  Add vimrc successfully..."
}

setup_pyenv()
{
    curl_install https://pyenv.run
    tee -a $profile <<-'EOF'
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
}

main()
{
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
echo "Well done, just run 'bash' for the updated profile to take effect."
