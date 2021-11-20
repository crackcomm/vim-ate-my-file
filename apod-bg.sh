#!/usr/bin/env bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

cd ~/Pictures
python3 $SCRIPTPATH/apod-wallpaper.py
gsettings set org.mate.background picture-filename `pwd`/bg.jpg

