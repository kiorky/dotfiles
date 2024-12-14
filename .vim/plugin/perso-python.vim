" -*- vim -*-
if has("python3")
    let b:py="python3"
else
    let b:py="python"
endif
exe b:py.' << EOF'
import vim
py = vim.eval('b:py')
pdbstr1="if not sys.stdin.isatty():realstdin=sys.stdin;sys.stdin=open(\"/dev/tty\");"
pdbstr4="import pdb;pdb.set_trace();"
pdbstrs=[pdbstr4, pdbstr1]
pdbstr3="import pdb;pdb.set_trace()"
pdbstrs=[pdbstr3]

epdbstr4="import epdb;epdb.serve();"
epdbstrs=[epdbstr4]

pdbclonestr="from pdb_clone import pdb as pdbc;pdbc.set_trace_remote()"
pdbclonestrs=[pdbclonestr]

remotepdbstr="import os as ros;ros.system('ip a 2>/dev/null||true');ros.environ['REMOTE_PDB_HOST']='0.0.0.0';ros.environ['REMOTE_PDB_PORT']='4444';from remote_pdb import set_trace;set_trace()"
remotepdbstrs=[remotepdbstr]

ipshell_str="from IPython.Shell import IPShellEmbed; ipshell = IPShellEmbed();ipshell()"
ipshell_str="import IPython; IPython.embed()"
ipshell_str="from IPython.frontend.terminal.embed import InteractiveShellEmbed;InteractiveShellEmbed().mainloop()"

def SetBreakpoint(strings=None):
    import re

    if not strings:
        strings = pdbstrs

    nLine = int( vim.eval( 'line(".")'))

    strLine = vim.current.line
    strWhite = re.search( r'^(\s*)', strLine).group(1)

    for brline in strings:
        vim.current.buffer.append(
           ("%(space)s"+brline+"  %(mark)s Breakpoint %(mark)s" ) %
             {'space':strWhite, 'mark': '#' * 2}, nLine - 1)

def RemoveAnyBreakpoints(strings=None):
    import re

    if not strings:
        strings = pdbstrs

    nCurrentLine = int( vim.eval( 'line(".")'))

    nLines = []
    nLine = 0
    for strLine in vim.current.buffer:
        for pdbshell_str in strings:
            if strLine.lstrip()[:len(pdbshell_str)] == pdbshell_str:
                nLines.append( nLine)

        nLine += 1

    nLines.reverse()

    for nLine in nLines:
        del vim.current.buffer[nLine]

def SetRPDBCLONEreakpoint(strings=None):
    return SetBreakpoint(strings=remotepdbstrs)

def RemoveAnyRPDBCLONEreakpoints(strings=None):
   return RemoveAnyBreakpoints(strings=remotepdbstrs)

def SetPCBreakpoint(strings=None):
    return SetBreakpoint(strings=pdbclonestrs)

def RemoveAnyPCBreakpoints(strings=None):
   return RemoveAnyBreakpoints(strings=pdbclonestrs)

def SetEBreakpoint(strings=None):
    return SetBreakpoint(strings=epdbstrs)

def RemoveAnyEBreakpoints(strings=None):
   return RemoveAnyBreakpoints(strings=epdbstrs)

def SetIPShell():
    return SetBreakpoint(strings=[ipshell_str])

def RemoveIPShell():
    return RemoveAnyBreakpoints(strings=[ipshell_str])

vim.command( 'map bb :'+py+' SetPCBreakpoint()<cr>')
vim.command( 'map bbb :'+py+' SetRPDBCLONEreakpoint()<cr>')
vim.command( 'map bbbb :'+py+' SetEBreakpoint()<cr>')
vim.command( 'map b :'+py+' SetBreakpoint()<cr>')
vim.command('map <s-b> :'
    +py+' RemoveAnyBreakpoints()<cr>:'
    +py+' RemoveAnyEBreakpoints()<cr>:'
    +py+' RemoveAnyPCBreakpoints()<cr>:'
    +py+' RemoveAnyRPDBCLONEreakpoints()<cr>')
vim.command( 'map <f7>  :'+py+' SetIPShell()<cr>')
vim.command( 'map <f8>  :'+py+' RemoveIPShell()<cr>')
EOF
" vim:set et sts=5 sw=4:
