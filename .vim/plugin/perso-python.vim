" -*- vim -*-
if has("python3")
    let b:py="python3"
else
    let b:py="python"
endif
exe b:py.' << EOF'
import vim
pdbstr1="if not sys.stdin.isatty():realstdin=sys.stdin;sys.stdin=open(\"/dev/tty\");"
pdbstr4="import pdb;pdb.set_trace();"
pdbstrs=[pdbstr4, pdbstr1]
pdbstr3="import pdb;pdb.set_trace()"
pdbstrs=[pdbstr3]

epdbstr4="import epdb;epdb.serve();"
epdbstrs=[epdbstr4]

ipshell_str="from IPython.Shell import IPShellEmbed; ipshell = IPShellEmbed();ipshell()"
ipshell_str="import IPython; IPython.embed()"
ipshell_str="from IPython.frontend.terminal.embed import InteractiveShellEmbed;InteractiveShellEmbed().mainloop()"

def SetBreakpoint(strings=None):
    import re

    if not strings:
        strings = pdbstrs

    nLine = int( vim.eval( 'line(".")'))

    strLine = vim.current.line
    strWhite = re.search( '^(\s*)', strLine).group(1)

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

def SetEBreakpoint(strings=None):
    return SetBreakpoint(strings=epdbstrs)

def RemoveAnyEBreakpoints(strings=None):
   return RemoveAnyBreakpoints(strings=epdbstrs)

def SetIPShell():
    return SetBreakpoint(strings=[ipshell_str])

def RemoveIPShell():
    return RemoveAnyBreakpoints(strings=[ipshell_str])

vim.command( 'map n :py SetEBreakpoint()<cr>')
vim.command( 'map N :py RemoveAnyEBreakpoints()<cr>')
vim.command( 'map b :py SetBreakpoint()<cr>')
vim.command( 'map <s-b> :py RemoveAnyBreakpoints()<cr>')
vim.command( 'map <f7> :py SetIPShell()<cr>')
vim.command( 'map <f8> :py RemoveIPShell()<cr>')
EOF
" vim:set et sts=4 sw=4:
