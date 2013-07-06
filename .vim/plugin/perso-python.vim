" -*- vim -*-

python <<EOF
import vim
pdbstr1="if not sys.stdin.isatty():realstdin=sys.stdin;sys.stdin=open(\"/dev/tty\");"
pdbstr4="import pdb;pdb.set_trace();"
#pdbstr2="from IPython.Debugger import Tracer; debug_here=Tracer();debug_here();"
#pdbstr3="if realstdin.isatty: sys.stdin=realstdin"
pdbstrs=[pdbstr4,pdbstr1]
#just pdb
pdbstr3="import pdb;pdb.set_trace()"
pdbstrs=[pdbstr3]
def SetBreakpoint():
    import re

    nLine = int( vim.eval( 'line(".")'))

    strLine = vim.current.line
    strWhite = re.search( '^(\s*)', strLine).group(1)

    for  brline in pdbstrs:
        vim.current.buffer.append(
           ("%(space)s"+brline+"  %(mark)s Breakpoint %(mark)s" ) %
             {'space':strWhite, 'mark': '#' * 2}, nLine - 1)

def RemoveAnyBreakpoints():
    import re

    nCurrentLine = int( vim.eval( 'line(".")'))

    nLines = []
    nLine = 0
    for strLine in vim.current.buffer:
        for pdbshell_str in pdbstrs:
            if strLine.lstrip()[:len(pdbshell_str)] == pdbshell_str:
                nLines.append( nLine)

        nLine += 1

    nLines.reverse()

    for nLine in nLines:
        del vim.current.buffer[nLine]

ipshell_str="from IPython.Shell import IPShellEmbed; ipshell = IPShellEmbed();ipshell()"
ipshell_str="import IPython; IPython.embed()"
ipshell_str="from IPython.frontend.terminal.embed import InteractiveShellEmbed;InteractiveShellEmbed().mainloop()"
def SetIPShell():
    import re

    nLine = int( vim.eval( 'line(".")'))

    strLine = vim.current.line
    strWhite = re.search( '^(\s*)', strLine).group(1)

    vim.current.buffer.append(
       ("%(space)s"+ipshell_str+" %(mark)s IPYTHON SHELL %(mark)s" ) %
         {'space':strWhite, 'mark': '#' * 30}, nLine - 1)

def RemoveIPShell():
    import re

    nCurrentLine = int( vim.eval( 'line(".")'))

    nLines = []
    nLine = 0
    for strLine in vim.current.buffer:
        if strLine.lstrip()[:len(ipshell_str)] == ipshell_str:
            nLines.append( nLine)
        nLine += 1

    nLines.reverse()

    for nLine in nLines:
        del vim.current.buffer[nLine]

vim.command( 'map b :py SetBreakpoint()<cr>')
vim.command( 'map <s-b> :py RemoveAnyBreakpoints()<cr>')
vim.command( 'map <f7> :py SetIPShell()<cr>')
vim.command( 'map <f8> :py RemoveIPShell()<cr>')
EOF
" vim:set et sts=4 sw=4:
