#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ] || [ "$1" != "nogit" ]
then
  cd $DIR/../ && git stash && git pull origin master
fi

# Restart node-red
cd $DIR/../node-red && npm install
cd $DIR/../node-red && ./run.sh

open ${DIR}/../processing/ui/application.macosx/ui.app
