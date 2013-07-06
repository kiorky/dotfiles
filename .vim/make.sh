#!/usr/bin/env bash
d=$PWD
./deploy.sh
cd $(dirname $0)
if [ ! -f bin/activate ];then
    virtualenv --no-site-packages .
    easy_install -U setuptools
fi
. bin/activate
python bootstrap.py
bin/buildout
git commit -am up
git push
