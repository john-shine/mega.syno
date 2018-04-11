#!/bin/sh

[ -z "${DISPLAY}" ] || /usr/bin/vncserver -kill ${DISPLAY} && sleep 3
/usr/bin/vncserver -geometry 800x600 -fg
