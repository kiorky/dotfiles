#!/usr/bin/env bash
cd $(dirname $0)
set -x
for i in .gitconfig .gitignore .hgrc .hgext .pdbrc .pylintrc .vimrc .vim;do ln -fs $PWD/$i ~/;done
ln -fs $PWD/py-setup.cfg ~/.flake8
