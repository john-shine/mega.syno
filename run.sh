#!/bin/bash

version=$(cat $(pwd "$0")/VERSION)
sudo docker run -d -p 4901:5901 -v "$(pwd)":"/MEGAsync" johnshine/mega.syno:${version}
