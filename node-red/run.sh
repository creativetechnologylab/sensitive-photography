#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR/settings.js
pm2 delete node-red
sleep 2
pm2 start /usr/local/bin/node-red -- -s $DIR/settings.js -v
