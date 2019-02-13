#!/bin/bash
source $(cd `dirname ${BASH_SOURCE[0]}`; pwd)/precondition.sh
source $(cd `dirname ${BASH_SOURCE[0]}`; pwd)/verify_pip.sh
CENTOS()
{
    pip install --user robotframework
    pip install --user robotframework-ride
    $YUMG "Development tools"
    $YUM mesa-libGL-devel
    $YUM mesa-libGLU-devel
    $YUM gstreamer-devel
    $YUM gstreamer-python-devel
    $YUM GConf2-devel
    $YUM gstreamer-plugins-base-devel
    $YUM xorg-x11-fonts-Type1

    wget http://downloads.sourceforge.net/wxpython/wxPython-src-2.8.12.1.tar.bz2
    tar -xjvf wxPython-src-2.8.12.1.tar.bz2
    cd wxPython-src-2.8.12.1/wxPython
    python build-wxpython.py --build_dir=../bld --install
}

$RELEASE
