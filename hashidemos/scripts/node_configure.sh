#!/bin/sh
#  Name: system_setup.sh
#  Author: Dan Fedick
#######################################
set -x # Uncomment to Debug

# install() {
#   sudo apt-get install $1
#   if [[ $? != 0 ]]
#   then
#     error "$1 was not installed correctly"
#     exit 7
#   else
#     success "$1 was installed successfully"
#     exit 0
#   fi
# }

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sleep 5
sudo apt-get update
sudo apt-get -y install vault
sudo apt-get -y install consul
sudo apt-get -y install nomad
