#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo npm install -g --unsafe-perm node-red
sudo npm install -g pm2
cd $DIR && npm install 
