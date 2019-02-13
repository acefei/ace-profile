#!/bin/bash
current_dir=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
source $current_dir/precondition.sh

sudo pip install charmy
charmy install
echo "alias pyc='~/PyCharm/pycharm-latest.sh  > /dev/null 2>&1 &'" >> ~/.bash_profile

echo 
echo "Please run 'source ~/.bash_profile' to take effect."
echo "Tips: run 'pyc' to start pycharm..."
