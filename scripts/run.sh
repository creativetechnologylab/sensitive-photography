#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ] || [ "$1" != "nogit" ]
then
  cd $DIR/../ && git stash && git pull origin master
fi

# Restart node-red
cd $DIR/../node-red && npm install
cd $DIR/../node-red && ./run.sh

# Images directory.
mkdir ~/Desktop/audio/

# Change config.
sed -i 's/gfoote/$USER/g' $DIR/../node-red/flow.json
sed -i 's/gfoote/$USER/g' $DIR/../node-red/flow_cred.json

sleep 2
open http://127.0.0.1:1880/
open ${DIR}/../processing/ui/application.macosx/ui.app
