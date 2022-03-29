#!/bin/sh
#  Name: system_setup.sh
#  Author: Dan Fedick
#######################################
# set -x # Uncomment to Debug

install() {
  sudo apt-get install $1
  if [[ $? != 0 ]]
  then
    error "$1 was not installed correctly"
    exit 7
  else
    success "$1 was installed successfully"
    exit 0
  fi
}

echo "Installing Docker-Compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update

sudo apt-get install vault
sudo apt-get install consul
sudo apt-get install nomad
