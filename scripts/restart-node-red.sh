#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Restart node-red
cd $DIR/../node-red && npm install
cd $DIR/../node-red && ./run.sh

