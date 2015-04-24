#!/usr/bin/env bash
cd $(dirname $0)

for i in .gitconfig .gitignore .hgrc .hgext .pdbrc .pylintrc .vimrc .vim;do ln -fs $PWD/$i ~/;done
