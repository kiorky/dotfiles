" autotagsgen.vim: Generate tags from the environment, specially for buildout based projects.
" Date:	        Oct. 17 2009
" Maintainer:	Mathieu PASQUET <kiorky@cryptelium.net>
" Distributable under the same terms as Vim itself (see :help license)
" DESCRIPTION
" This plugin handles the generation of tags with exuberants ctags for you
" You must have a python enabled vim. (+python)
" if you do not set g:AGTuseLocalTags in your configuration it will generate tags in ~/.vim/tags/FILETYPE
" Otherwise, it will generate them in ./tags.FILETYPE
" Originally i made this script to manage tags for python and html dev around zope projects managed via buildout.
" The trip was to generate a variable somewhere (PYTHONPATH) where i have all my python dependencies.
" It looks also in the OMELETTE env var (: separated as in sys.path)
" And from there, this vim scripts look for tags.
" It is evident that for now the scripts handles just python and html/js file and takes its input paths from PYTHONPATH
" but improvments are not difficult although i have no need to do that but patchs are welcome.
"
" You should really use the local tags feature with just that in your vimrc:
"
" let g:AGTuseLocalTags=1
"
" for Buildout users, to do so use that as an exemple
"
" [part]
" recipe = minitage.recipe.[scripts, egg}
" eggs = someeggs
" env-file=foo.env
"
" bin/buildout install part # buildout dance
"
" Then in your shell session, register the .env with:
" . foo.env
"
" That's it, the plugin will now all about your project dependencies and will generate tags from there.
"
" Everytime you open a file, this plugin will register automaticly the appropriate tags
" Think that with local tags, it generates the tags in the current directory, so launch vi from the same place or the tags will have to be regenerated
"
" ===============================================================================================================
" ALSO, THE GENERATION IS NOT AUTOMATIC AS IT CAN BE RESOURCE INTENSIVE, ISSUE THE ",,t" DANCE MANUALLY!!!
" ===============================================================================================================
"
" the script repository lives in my config aggregate : http://hg.cryptelium.net/hg/system/config/vim (mercurial)
"
" Mapping
" Action (Normal mode)                              Mapping
" =========================================================
" Regenerate tags                                   ,,e
" Manually Register tags for current session        ,,n
" GetLatestVimScripts: 1075 1 :AutoInstall: autotagsgen.vim

" mappings {{{
if !exists('g:AGTuseLocalTags')
    let g:AGTuseLocalTags = 0
endif
" }}}
" plugin {{{
"if 0
if has("python")
python << EOF
# mappings {{{
import vim
vim.command("map ,,e :py pygentags()<CR>")
vim.command("map ,,n :py register_ctagsfiles()<CR>")
vim.command("autocmd BufRead,BufNewFile * python register_ctagsfiles()")
# }}}
# imports & helper {{{
import os
import sys
import subprocess
from subprocess import PIPE
def uniquify(ol):
    l = []
    [l.append(i)
        for i in ol
        if not i in l]
    return l

def which(program, environ=None, key = 'PATH', split = ':'):
    if not environ:
        environ = os.environ
    PATH=environ.get(key, '').split(split)
    fp = None
    if '/' in program:
        fp = os.path.abspath(program)
    if not fp:
        for entry in PATH:
            fp = os.path.abspath(os.path.join(entry, program))
            if os.path.exists(fp):
                break
    if os.path.exists(fp):
        return fp
    raise IOError('Program not fond: %s in %s ' % (program, PATH))
# }}}
# ctags {{{
ctags_binary = 'exuberant-ctags'
tags_homedir = os.path.expanduser(os.path.join('~', '.vim', 'tags'))
try:
    if not os.path.exists(tags_homedir):
        os.makedirs(tags_homedir)
except:
    tags_homedir = os.path.expanduser(os.path.join(os.getcwd(), '.vim', 'tags'))
    os.makedirs(tags_homedir)
try:
    try:
        ctags_binary = which(ctags_binary)
    except:
        try:
            ctags_binary = which('ctags')
        except Exception, e:
            raise e


    def get_supported_fts():
        return ['php', 'python', 'xml', 'html', 'zpt', 'xhtml', 'js']

    def isSupportedFt(filetype):
        return filetype in get_supported_fts()

    def get_python_paths():
        paths, upaths = sys.path, []
        paths.extend(
            [a
            for a in os.environ.get('OMELETTE', '').split(':')
            if os.path.exists(a) and not a in paths]
        )
        paths.append(os.path.dirname(os.__file__))
        paths.sort()
        noecho = [upaths.append(path)
                  for path in paths
                  if not path in upaths and os.path.isdir(path)]
        upaths.sort()
        return upaths

    def get_filetype(filetype=None):
        if filetype:
            return filetype
        return vim.eval('&filetype')

    def get_tagsfile(filetype):
        default_file = os.path.join(tags_homedir, filetype)
        my_file = default_file
        cwd = os.environ.get('INS', os.getcwd())
        if vim.eval('g:AGTuseLocalTags') == '1':
            my_file = os.path.join(cwd, 'tags.%s' % filetype)
        return my_file

    def register_ctagsfiles(filetype=None):
        filetype = get_filetype(filetype)
        tag = get_tagsfile(filetype)
        if isSupportedFt(filetype):
            vim.command("set tags=./tags,./TAGS,tags,TAGS,%s" % (tag))
            #print "Registration of %s complete, go to work!" % (tag)

    def pygentags(filetype=None):
        filetype = get_filetype(filetype)
        paths = []
        if filetype in ('HTML', 'python'):
            paths = get_python_paths()
        if filetype == 'php':
            paths = [os.path.join(os.environ.get('INS', '.'), 'src')]
        lf = '--filetype-force=%s' % filetype
        if filetype in ['python']:
            lf += ',C,C++'
        if filetype in ['HTML']:
            lf += ',JavaScript'
        ec_cli = [ctags_binary,
            '-a',
            '--tag-relative=no',
            '--fields=+afikKlmnsSzt',
            '--recurse=yes',
            '--sort=yes',
            '--links=yes',
            '--languages=+%s' % filetype,
            '--verbose=no',
            ]
        if filetype == 'HTML':
          ec_cli.extend(['-h .pt.zcml.html.xhtml.xml'],)
        #vim.command("echo 'Generating tagsfiles, please wait !!!'")
        for i, path in enumerate(paths):
            #if i % 5 == 0: vim.command("echo '...'")
            cli = ec_cli[:]
            tagsfile = get_tagsfile(filetype)
            #print "Generating tagsfile for %s in %s" % (path, tagsfile)
            cli.extend(['-f', tagsfile])
            cli.append(path)
            p = subprocess.Popen(" ".join(cli), shell=True, stdout=PIPE, stderr=PIPE)
            p.wait()
        register_ctagsfiles(filetype)
        print "Generation of %s complete, go to work!" % (get_tagsfile(filetype))
except:
    pass
# }}}
EOF
endif
" }}}
" vim: foldmethod=marker :
