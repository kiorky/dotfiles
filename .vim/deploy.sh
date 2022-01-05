#!/usr/bin/env bash
if [ $(whoami) != root ];then
    cd $(dirname $0)
    d=$PWD
    if [ ! -h $HOME/.vim ];then
        mv $HOME/.vim "$HOME/.vim.old.$(date "+%F")"
    fi
    if [ ! -h $HOME/.vimrc ];then
        mv $HOME/.vimrc "$HOME/.vimrc.old.$(date "+%F")"
    fi
    ln -sf "$d" "$HOME/.vim"
    ln -sf  "$HOME/.vim/vimrc" "$HOME/.vimrc"
    cd $HOME/.vim
    if [ ! -d $HOME/.config ];then
        mkdir -pv $HOME/.config
    fi
    IGN="E226,E241,E242,E126,E501,W402,W802,F0401,W0622"
    IGN="E241,E242,W802,F0401,W0622,W0142"
    cat>$HOME/.config/flake8 <<EOF
[flake8]
ignore = $IGN
EOF
    cat>$HOME/.config/pep8 <<EOF
[flake8]
ignore = $IGN
EOF
fi
cd $(dirname $0)
nsp=""
if ( virtualenv --help |grep -q -- --no-site-packages );then
    nsp="--no-site-packages"
fi
if [ ! -f venv3/bin/activate ];then
    virtualenv $nsp --python python3 venv3
fi
if [ ! -f venv/bin/activate ];then
    virtualenv $nsp --python python2 venv
fi
if [ -f venv/bin/activate ];then
    echo "installing py stuff"
    . venv/bin/activate
    pip install --upgrade -r requirements.txt
    deactivate
fi
if [ -f venv3/bin/activate ];then
    echo "installing py3 stuff"
    . venv3/bin/activate
    pip install --upgrade -r requirements3.txt -r requirements.txt
    deactivate
fi
