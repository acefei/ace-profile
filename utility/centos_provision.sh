#!/bin/bash

update_resolv_conf() {
tee /etc/resolv.conf <<EOF
# /etc/resolv.conf
nameserver 114.114.114.114
nameserver 119.29.29.29
EOF
}

install_requirement() {
    # dev tools
    yum groupinstall -y "Development Tools"
    
    yum install -y git
    
    # jdk for intelliJ tools
    yum install java-1.8.0-openjdk-devel.x86_64

    # chinese fonts
    yum install -y wqy-microhei-fonts
}

download_163_yum_repo() {
    pushd /etc/yum.repos.d/ 
    [ -e CentOS-Base.repo ] && mv CentOS-Base.repo CentOS-Base.repo.backup
    curl -o CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
    yum clean all
    yum makecache
    popd
}

main() {
    update_resolv_conf 
    download_163_yum_repo
    install_requirement
}

main
