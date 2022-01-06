" Vim plugin
" Purpose: create files with template
" Author: Mathieu PASQUET <kiorky@cryptelium.net>
" Copyright:  Copyright (c) 2008 Mathieu PASQUET <kiorky@cryptelium.net>
" License: You may redistribute this under the same terms as Vim itself

" set that in your envrionnement to override templates:
" vim_mail : author part
" vim_comment : filetype comment charracter
" vim_license : one of the license in the LICENSES dict
" vim_python_doc : one of the docformats in the python_doc dict

if &compatible || v:version < 603
    finish
endif
if has("python3")
    command! -nargs=1 Py py3 <args>
    let b:py="python3"
else
    command! -nargs=1 Py py <args>
    let b:py="python"
endif
exe b:py.' << EOF'
import vim
import os
import sys
import datetime
LICENSES = {
    'gpl' :'''
%(comment)s Copyright (C) %(year)s, %(mail)s
%(comment)s
%(comment)s This program is free software; you can redistribute it and/or modify
%(comment)s it under the terms of the GNU General Public License as published by
%(comment)s the Free Software Foundation; either version 2 of the License, or
%(comment)s (at your option) any later version.
%(comment)s
%(comment)s This program is distributed in the hope that it will be useful,
%(comment)s but WITHOUT ANY WARRANTY; without even the implied warranty of
%(comment)s MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%(comment)s GNU General Public License for more details.
''',
'bsd': '''
%(comment)s Copyright (C) %(year)s, %(mail)s
%(comment)s All rights reserved.
%(comment)s
%(comment)s Redistribution and use in source and binary forms, with or without
%(comment)s modification, are permitted provided that the following conditions are met:
%(comment)s
%(comment)s 1. Redistributions of source code must retain the above copyright notice,
%(comment)s    this list of conditions and the following disclaimer.
%(comment)s 2. Redistributions in binary form must reproduce the above copyright
%(comment)s    notice, this list of conditions and the following disclaimer in the
%(comment)s    documentation and/or other materials provided with the distribution.
%(comment)s 3. Neither the name of the <ORGANIZATION> nor the names of its
%(comment)s    contributors may be used to endorse or promote products derived from
%(comment)s    this software without specific prior written permission.
%(comment)s
%(comment)s THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%(comment)s AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%(comment)s IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%(comment)s ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%(comment)s LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%(comment)s CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%(comment)s SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%(comment)s INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%(comment)s CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%(comment)s ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%(comment)s POSSIBILITY OF SUCH DAMAGE.
''',
'none' : '',
}

PYTHON_MISC = '''\
%(comment)s!/usr/bin/env python
from __future__ import absolute_import, division, print_function
__docformat__ = \'%(python_doc)s\'
'''
PYTHON_MISC = '''\
%(comment)s!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function
'''

python_doc = {'rst':'restructuredtext en'}
python_encoding = {'utf8':'utf-8'}
def makeVimTemplate(ft='sh', options=dict()):
    EXE = None
    MISC = None
    ENC = ''
    LICENSE = LICENSES.get(options['license'], 'gpl') % options
    LICENSE = LICENSES.get('none', 'gpl') % options
    SHEBANG = "%(comment)s vim:set et sts=4 ts=4 tw=80:" % options
    if ft == 'python':
        SHEBANG = "%(comment)s vim:set et sts=4 ts=4 tw=120:" % options
        EXE = ''
        ENC = ''
        MISC = PYTHON_MISC % options
    if ft == 'sh':
        EXE = '%(comment)s!/usr/bin/env bash'%options
    if ft == 'php':
        EXE = '<?php'
        SHEBANG += '\n?>'
    return '\n'.join([i for i in (EXE, ENC, LICENSE, MISC, SHEBANG) if i])

def getEnvAndMakeTemplate(ft='sh'):
    if ft in ['python','sh']:
        comment = '#'
    if ft in ['c','php']:
        comment = '//'
    template_options = {
        'mail':os.environ.get('vim_mail','Mathieu Le Marec - Pasquet <kiorky@cryptelium.net>'),
        'comment':os.environ.get('vim_comment',comment),
        'year': datetime.datetime.now().strftime('%Y'),
        'license': os.environ.get('vim_license','bsd'),
        }
    if ft == 'python':
        template_options['python_doc'] = python_doc.get(os.environ.get('vim_python_doc','rst'),'rst')
        template_options['python_enc'] = python_encoding.get(os.environ.get('vim_python_encoding','utf8'),'utf8')
    mystring = makeVimTemplate(ft, template_options)
    vim.current.buffer[:] = mystring.split('\n')
EOF
com! -nargs=0 NewPythonFile py getEnvAndMakeTemplate()
augroup NewCrypteliumFile
    au!
    autocmd BufNewFile *.py,*.vpy,*.cpy
                \ Py getEnvAndMakeTemplate(ft='python')
    autocmd BufNewFile *.php
                \ Py getEnvAndMakeTemplate(ft='php')
    autocmd BufNewFile *.sh,*.bash
                \ Py getEnvAndMakeTemplate(ft='sh')
augroup END
