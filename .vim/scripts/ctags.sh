#!/usr/bin/env bash
# generate tag file for path to use for completion/source browsing
if [[ $1 == "silent" ]];then
    SILENT="1"
fi
if [[ $(uname) == 'FreeBSD' ]]  ;then
    CTAGS="/usr/local/bin/exctags"
elif [[ $(uname) == 'Darwin' ]];then
    CTAGS="/opt/local/bin/ctags"
elif [[ $(grep Ubuntu /etc/issue|wc -l) -lt 1 ]];then
    CTAGS="/usr/bin/exuberant-ctags"
elif [[ $(grep Ubuntu /etc/issue|wc -l) -eq 1 ]];then
    CTAGS="/usr/bin/ctags"
fi
CTAGS_OUT_PATH="${HOME}/.vim/ctags_tagfiles"
if [[ $(uname) == 'FreeBSD' ]] || [[ $(uname) == 'Darwin' ]];then
    SED="gsed"
else
    SED="sed"
fi
TAGGEDS="php jpc zope python makinatest anticancer eptb minitage"
# record tags for a path in specified outfile
# $1 : path          # $2 : outfile    $3 -> $* ctags flags
exe_rec_ctags(){
    local language="$3" outfile="$2" path="$1"
    [[ -f $outfile ]] && rm -f  "$outfile"
    if [[ -z $SILENT ]];then
        COMMON="--totals --recurse -o $outfile $1"
    else
        COMMON="--verbose=no --totals=no --recurse -o $outfile "
    fi
    case $language in
        "php")
        $CTAGS  \
        --tag-relative=yes \
        --PHP-kinds=+cf \
        --regex-PHP="/abstract class ([^ ]*)/\1/c/" \
        --regex-PHP="/interface ([^ ]*)/\1/c/" \
        --regex-PHP="/(public |static |abstract |protected |private )+function ([^(]*)/\2/f/" \
        $COMMON
        ;;
        "py")
        if [[ -d "$path" ]];then
            pushd $path 2>&1 >>  /dev/null
            echo $CTAGS  -h ".py" \
            --tag-relative=no  --fields=+afikKlmnsSzt\
            --language-force=python --languages=+python \
            $COMMON $path
            popd 2>&1 >>  /dev/null
        fi
        ;;
        *)
        $CTAGS $COMMON
    esac
    genere_ctags_vim "${outfile}"
}
# generat ctags tagfiles path setter plugin
genere_ctags_vim() {
    # default vim path
    local CTAGS_CMD="set tags=./tags,./TAGS,tags,TAGS"
    # our generated ctags path setter plugin
    local CTAGS_SETPLUG="${HOME}/.vim/plugin/ctags_setter.vim"
    # for each tag file in $@
    for i in ${@};do
        # ensure tag file exists
        if [[ -f "${i}" ]];then
            nbli=0
            if [[ -f "$CTAGS_SETPLUG" ]];then
                nbli=$(egrep "set.*tags" ${CTAGS_SETPLUG}|wc -l)
            fi
            # if we havent allready append some stuff, add default vim path
            if [[ $nbli -lt 1 ]];then
                echo "${CTAGS_CMD}" >> "${CTAGS_SETPLUG}"
            fi
            # keep one line
            lastli="$(tail -n1 ${CTAGS_SETPLUG})"
            #trim lastli
            lastli="$(echo $lastli|$SED -re "s/\s*$//g")"
            #remove our tags
            lastli="$(echo $lastli|$SED -re "s:(,)*$i::g")"
            # append our tagfile path
            echo "$lastli,$i" > "${CTAGS_SETPLUG}"
        fi
    done
}
python_tags() {
    exe_rec_ctags /mnt/fast/stage3/usr/lib/python2.4/ "${CTAGS_OUT_PATH}/python-2.4.tags" py
}
zope_tags() {
    exe_rec_ctags /home/kiorky/projects/zope/ctagszope "${CTAGS_OUT_PATH}/zope.tags" py
}
makinatest_tags() {
    exe_rec_ctags /home/kiorky/projects/zope/makina/products "${CTAGS_OUT_PATH}/makinatestpr.tags" py
    exe_rec_ctags /home/kiorky/projects/zope/makina/src "${CTAGS_OUT_PATH}/makinatestsr.tags" py
}
anticancer_tags() {
    #zope_tags
     exe_rec_ctags  /home/kiorky/projects/zope/anticancer/parts    "${CTAGS_OUT_PATH}/anticancer_thirdparty.tags" py 2>&1 |egrep -v "Warning|Unexpec"
    #perso_tags
    exe_rec_ctags  /home/kiorky/projects/zope/anticancer/Products "${CTAGS_OUT_PATH}/anticancerpr.tags" py
}
makina_tags() {
    local pref="/home/kiorky/projects/zope/minitage-0.4/"
    #zope_tags
     exe_rec_ctags  $pref/misc/buildbot/src       "${CTAGS_OUT_PATH}/makina.buildbot.tags"     py   2>&1 |egrep -v "Warning|Unexpec"
     exe_rec_ctags  $pref/eggs/cache/              "${CTAGS_OUT_PATH}/misc.tags"                py   2>&1 |egrep -v "Warning|Unexpec"
}
eptb_tags() {
    local pref="/home/kiorky/projects/zope/minitage/instances/eptb17-prod/"
    #zope_tags
     exe_rec_ctags  $pref/parts/plone              "${CTAGS_OUT_PATH}/eptb_thirdparty.plone.tags"          py   2>&1 |egrep -v "Warning|Unexpec"
     exe_rec_ctags  $pref/parts/productdistros/    "${CTAGS_OUT_PATH}/eptb_thirdparty.productsdistro.tags" py   2>&1 |egrep -v "Warning|Unexpec"
     exe_rec_ctags  $pref/parts/zope2/lib/python/  "${CTAGS_OUT_PATH}/eptb_thirdparty.zope.tags"           py   2>&1 |egrep -v "Warning|Unexpec"
    exe_rec_ctags  $pref/.vim                     "${CTAGS_OUT_PATH}/eptb.products.tags"                  py   2>&1 |egrep -v "Warning|Unexpec"
     exe_rec_ctags  $pref/src/HFW/HFW              "${CTAGS_OUT_PATH}/eptbhfw.tags"                        py   2>&1 |egrep -v "Warning|Unexpec"
}
jpc_tags() {
    local pref="/home/kiorky/projects/zope/minitage/instances/eptb17/"
    #zope_tags
     exe_rec_ctags "/Users/jpcw/devel/go/airport/aicc/parts/"   "${CTAGS_OUT_PATH}/eptb_thirdparty.plone.tags"       py   2>&1 |egrep -v "Warning|Unexpec"
}
minitage_tags() {
 	exe_rec_ctags "/home/kiorky/projects/minitage/hg/eggs"     "${CTAGS_OUT_PATH}/egg_minitage.core.tags"       py     2>&1 |egrep -v "Warning|Unexpec"
 	exe_rec_ctags "/home/kiorky/tmp/foo/lib/python2.5/site-packages/"        "${CTAGS_OUT_PATH}/eggsample"       py      2>&1 |egrep -v "Warning|Unexpec"
} 
guerir_tags() {
    local pref="/home/kiorky/projects/zope/minitage-0.4/zope/guerir-dev"
    #zope_tags
     exe_rec_ctags "$pref/parts/omelette/"   "${CTAGS_OUT_PATH}/antiegg_omelette.tags"       py   2>&1 |egrep -v "Warning|Unexpec"
     exe_rec_ctags "$pref/omelette/src"   "${CTAGS_OUT_PATH}/antiegg_src.tags"       py   2>&1 |egrep -v "Warning|Unexpec"
     exe_rec_ctags "$pref/parts/zope2"   "${CTAGS_OUT_PATH}/antiegg_zope.tags"       py   2>&1 |egrep -v "Warning|Unexpec"
}
c_tags() {
    local pref="$(ls -d /home/kiorky/tmp/minitage/pylons/c*ma 2>&1)"
    local mt="$(ls -d /home/kiorky/tmp/minitage/ 2>&1)"
    if [[ ! -d $pref ]];then
        pref="$(ls -d /home/kiorky/projects/zope/minitage-0.4/pylons/c*ma)"
        mt="$(ls -d /home/kiorky/projects/zope/minitage-0.4)"
    fi
    #zope_tags
     exe_rec_ctags "$pref/parts/omelette/"   "${CTAGS_OUT_PATH}/egg_omelette.tags"  py 2>&1 |egrep -v "Warning|Unexpec"
#     exe_rec_ctags "$mt/eggs/cache"   "${CTAGS_OUT_PATH}/egg.tags"  py 2>&1 |egrep -v "Warning|Unexpec"
}
php_tags() {
    exe_rec_ctags /var/www/nightly-build "${CTAGS_OUT_PATH}/makina.tags" php
}

usage() {
    echo " $0 [LANG1 ... LANGN]"
    echo "Avaibles tags searches are:"
    for tagged in $TAGGEDS;do
        echo "    * $tagged"
    done
}
for arg in $@;do
    for tagged in $TAGGEDS;do
        if [[ $arg ==  $tagged ]];then
            ${tagged}_tags
            COOL_END="Y"
        fi
    done
done
[[ -z $COOL_END ]] && usage

