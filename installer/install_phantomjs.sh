#!/bin/bash
current_dir=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
source $current_dir/sudo_detection.sh

cd /tmp && \
    curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    tar jxf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin && \
    rm -rf phantomjs-2.1.1-linux-x86_64.tar.bz2 phantomjs-2.1.1-linux-x86_64
