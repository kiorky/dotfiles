#!/usr/bin/env bash
d=${PWD}
cd $(dirname ${0})
nodl=""
nodeploy=""
for i in $@;do
    if [ "x${i}" != "xnodeploy" ];then
        nodeploy="1"
    fi
    if [ "x${i}" != "xnosync" ];then
        nodl="1"
    fi
done
declare -A REPOS
if [ "x${nodeploy}" = "x" ];then
    ./deploy.sh
fi
REPOS[gruvbox]="https://github.com/morhetz/gruvbox.git"
REPOS[base16]="https://github.com/chriskempson/base16-vim.git"
REPOS[jinja]="https://github.com/lepture/vim-jinja.git"
# HARMFULL !!!
#REPOS[vim-css-color]="https://github.com/skammer/vim-css-color.git"
REPOS[vim-css3]="https://github.com/hail2u/vim-css3-syntax.git"
REPOS[vim-less]="https://github.com/groenewege/vim-less.git"
REPOS[vim-golang]="https://github.com/jnwhiteh/vim-golang.git"
REPOS[solarized]="git://github.com/altercation/vim-colors-solarized.git"
REPOS[saltvim]="https://github.com/saltstack/salt-vim.git"
REPOS[Pathogen]="https://github.com/tpope/vim-pathogen.git"
REPOS[sieve]="https://github.com/vim-scripts/sieve.vim.git"
REPOS[rest]="https://github.com/vim-scripts/rest.vim.git"
REPOS[php]="https://github.com/StanAngeloff/php.vim.git"
REPOS[mako]="https://github.com/vim-scripts/mako.vim.git"
REPOS[doctest]="https://github.com/vim-scripts/doctest-syntax.git"
REPOS[dhcpd]="https://github.com/vim-scripts/dhcpd.vim.git"
REPOS[grep]="https://github.com/vim-scripts/grep.vim.git"
REPOS[tail]="https://github.com/vim-scripts/Tail-Bundle.git"
REPOS[pf]="https://github.com/vim-scripts/pf.vim.git"
REPOS[SeeTab]="https://github.com/vim-scripts/SeeTab.git"
REPOS[dirdiff]="https://github.com/vim-scripts/DirDiff.vim.git"
REPOS[dockerfile]="https://github.com/ekalinin/Dockerfile.vim.git"
REPOS[Align]="https://github.com/vim-scripts/Align.git"
REPOS[AnsiEsc]="https://github.com/vim-scripts/AnsiEsc.vim.git"
REPOS[DrawIt]="https://github.com/vim-scripts/DrawIt.git"
REPOS[EasyAccents]="https://github.com/vim-scripts/EasyAccents.git"
REPOS[Engspchk]="https://github.com/vim-scripts/Engspchk.git"
REPOS[EnhancedCommentify]="https://github.com/hrp/EnhancedCommentify.git"
REPOS[fencview]="https://github.com/vim-scripts/FencView.vim.git"
REPOS[matchit]="https://github.com/vim-scripts/matchit.zip.git"
REPOS[ragrat]="https://github.com/vim-scripts/ragtag.vim.git"
REPOS[visincr]="https://github.com/vim-scripts/VisIncr.git"
REPOS[term]="https://github.com/vim-scripts/term.vim.git"
REPOS[taglist]="https://github.com/vim-scripts/taglist.vim.git"
REPOS[scriptease]="https://github.com/tpope/vim-scriptease.git"
REPOS[surround]="git://github.com/tpope/vim-surround.git"
REPOS[po]="https://github.com/vim-scripts/po.vim.git"
REPOS[vimball]="https://github.com/vim-scripts/Vimball.git"
REPOS[blockhl]="https://github.com/vim-scripts/BlockHL.git"
REPOS[decho]="https://github.com/vim-scripts/Decho.git"
REPOS[GetLatestVimScripts]="https://github.com/vim-scripts/GetLatestVimScripts.git"
REPOS[gnupg]="https://github.com/vim-scripts/gnupg.vim.git"
REPOS[javascript]="https://github.com/pangloss/vim-javascript.git"
REPOS[netrw]="https://github.com/vim-scripts/netrw.vim.git"
REPOS[Astronaut]="https://github.com/vim-scripts/Astronaut.git"
REPOS[syntastic]="https://github.com/scrooloose/syntastic.git"
REPOS[vim-markdown]="https://github.com/plasticboy/vim-markdown.git"
if [ "x${nodl}" = "x" ];then
    for i in "${!REPOS[@]}";do
        repo="${d}/dl/${i}"
        crepo="$(dirname "${repo}")"
        clone_uri="${REPOS[$i]}"
        if [ ! -d "${crepo}" ];then
            mkdir -p "${crepo}"
        fi
        echo "${repo} <- ${clone_url}t "
        if [ ! -d "${repo}" ];then
            cd ${crepo}
            git clone ${clone_url} $(basename ${repo}) 1>/dev/null
        fi
        cd "${repo}"
        git fetch --all 1>/dev/null
        git reset --hard $(git ls-remote ${clone_url}|grep HEAD|awk '{print $1}')
    done
fi
rsync -azv "${d}/dl/" "${d}/bundle/" --exclude=.git --delete
git commit -am up
git push
