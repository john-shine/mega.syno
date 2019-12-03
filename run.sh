#!/bin/bash

version=$(cat $(pwd "$0")/VERSION)
sudo docker run -d -p 5901:5901 -p 6080:6080 -v "$(pwd)"/MEGA:"/home/mega/MEGA" johnshine/mega.syno:${version}
