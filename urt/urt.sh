#!/usr/bin/env bash
cd "$(dirname $(readlink -f $0))/.."
setxkbmap us
./Quake3-UrT.x86_64
setxkbmap fr
# vim:set et sts=4 ts=4 tw=80:
