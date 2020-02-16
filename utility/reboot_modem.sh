#!/bin/sh

ip='192.168.1.1'
user='useradmin'
pass=''

while getopts ":i:u:p:" opt; do
  case $opt in
    i)
      echo "modem ip is $OPTARG" 
      ip=$OPTARG
      ;;
    u)
      echo "username is $OPTARG" 
      user=$OPTARG
      ;;
    p)
      echo "password is $OPTARG" 
      pass=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" 
      ;;
  esac
done
