#!/bin/bash

setup=$(mktemp -dt "$(basename "$0").XXXXXXXXXX")
teardown(){
    exit_code=$?
    rm -rf "$setup"
    if [ $exit_code -eq 0 ];then
        echo
        echo "Installation complete!"
        ask_exit
    else
        exit $exit_code
    fi
}
trap teardown EXIT 

current_dir=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
source $current_dir/provision.sh

essential() {
    install['yum']="epel-release gcc automake autoconf libtool make git-lfs"
    install['apt']="build-essential automake nfs-common git-lfs"
    install_pack ${install["$pm"]}
    echo "===> essential is installed successfully."
}

setup_pyenv() {
    curl_install https://pyenv.run
    pyenvrc=~/.pyenvrc
    tee $pyenvrc <<-'EOF'
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
    export PATH="$HOME/.pyenv/bin:$PATH"
    echo "source $pyenvrc" >> $profile
}

make_python3() {
    remove_pack python3 || :
    setup_pyenv

    ver=3.7.2
    PY3_PREFIX=$HOME/.pyenv/versions/$ver
    if [ ! -d "$PY3_PREFIX" ];then
        # install dependency
        install['yum']="ncurses-devel zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel"
        install['apt']="make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl"
        install_pack ${install["$pm"]}
        pyenv install $ver
        PY3_PREFIX=`pyenv prefix $ver`
    fi 
    pyenv global $ver
    eval "$(pyenv init -)"
    export PY3_CONFIG=`$PY3_PREFIX/bin/python-config --configdir`
    echo "===> python $ver is installed successfully."
}

make_vim8() {
    if [ $pm == 'apt' ];then
        install_pack 'vim-nox'
        return
    fi

    test -e $local_bin/vim && return
    make_python3

    # re-build vim8 with huge feature
    install['yum']="ncurses-devel perl-devel perl-ExtUtils-Embed ruby-devel lua-devel"
    install['apt']="libncurses5-dev libperl-dev ruby-dev lua5.1 liblua5.1-dev luajit libluajit-5.1"
    install_pack ${install["$pm"]}
    echo "===> vim depandencies are installed successfully."
    
    cd $setup
    get_from_github vim
    cd vim
    #  run `make distclean' and/or `rm config.cache' and start over

    make distclean 
    ./configure --with-features=huge          \
                --enable-python3interp=yes    \
                --with-python3-config-dir=$PY3_CONFIG  \
                --enable-rubyinterp=yes       \
                --enable-perlinterp=yes       \
                --enable-luainterp=yes        \
                --enable-fail-if-missing      \
                --prefix=$local_dir           
    make -j$CPUS    
    make install 

    if ! grep -q "alias vi=$local_bin/vim" $profile; then 
        echo "alias vi=$local_bin/vim" >> $profile
    fi
    git config --global core.editor "$local_bin/vim"
    echo "===> vim is installed successfully."
}

docker_utils() {
    # refer to https://get.daocloud.io
    if [ ! -x "$(command -v docker)" ]; then
        curl -sSL https://get.daocloud.io/docker | $gosu sh
    fi
    echo "===> docker is installed successfully."

    if [ ! -e $local_bin/docker-compose ]; then
        curl -L https://get.daocloud.io/docker/compose/releases/download/1.20.1/docker-compose-`uname -s`-`uname -m` > $local_bin/docker-compose
        chmod +x $local_bin/docker-compose
    fi
    echo "===> docker-compose is installed successfully."

    $gosu usermod -aG docker $USER

    # configure docker service
    docker_service_file=/usr/lib/systemd/system/docker.service
    if [ -e $docker_service_file ];then
        $gosu sed -i 's!^\(ExecStart=\).*!\1/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock!' $docker_service_file
    fi
}

make_tmux(){
    if [ $pm == 'apt' ];then
        install_pack 'tmux'
        return
    fi

    test -e $local_bin/tmux && return

    install['yum']="xsel xclip"
    # install['apt']="xsel xclip byacc"
    install_pack ${install["$pm"]}

    cd $setup
    # download source files for tmux, libevent and ncurses
    get_from_github tmux
    get_from_github libevent
    curl -L ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz -o ncurses.tar.gz
    tar xvzf ncurses.tar.gz

    # libevent
    cd $setup/libevent*
    ./autogen.sh
    ./configure --prefix=${local_dir} --disable-shared
    make -j$CPUS
    make install

    # ncurses
    cd $setup/ncurses-*
    export CPPFLAGS="-P" # otherwise ncurse fails to build on gcc 5.x (https://gcc.gnu.org/bugzilla/show_bug.cgi?id=61832)
    ./configure --prefix=${local_dir} --without-debug --without-shared --without-normal --without-ada
    make -j$CPUS
    make install

    # tmux
    cd $setup/tmux*
    ./autogen.sh
    ./configure CFLAGS="-I$local_dir/include -I$local_dir/include/ncurses" LDFLAGS="-L$local_dir/lib -L$local_dir/include/ncurses -L$local_dir/include"
    CPPFLAGS="-I$local_dir/include -I$local_dir/include/ncurses" LDFLAGS="-static -L$local_dir/include -L$local_dir/include/ncurses -L$local_dir/lib"
    make -j$CPUS
    cp tmux $local_dir/bin

    # tmux plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    # add tmux config
    ln -sf $config/tmux.conf $tmuxconfig 
    echo ">>>>>  Add tmux config successfully..."

    echo "===> tmux is installed successfully."
}

setup_virt() {
    install['apt']="bridge-utils virtinst"
    install_pack ${install["$pm"]}
    echo "===> KVM is installed successfully."
}

setup_python_formatter() {
    install['apt']="python3-pip"
    install_pack ${install["$pm"]}

    $gosu pip3 install black isort
    echo "===> python formatter are installed successfully."
}

setup_shellcheck() {
    install['apt']="shellcheck"
    install_pack ${install["$pm"]}
    echo "===> shellcheck is installed successfully."
}

main() {
    # select what you want to install
    essential
    make_tmux
    make_vim8
    setup_virt
    setup_shellcheck
    setup_python_formatter
    #docker_utils
}

main
