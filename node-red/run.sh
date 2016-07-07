#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pm2 stop node-red
pm2 start /usr/local/bin/node-red -- -s $DIR/settings.js -v
