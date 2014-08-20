if has("python3")
    let b:py="python3"
else
    let b:py="python"
endif
exe b:py.' << EOF' 
import sys
import vim
def SqlDecaps(mode):
    cb = vim.current.buffer
    header_match_exact=[
    "IS NULL"
    ,"END IF"
    ,"FOR EACH ROW"
    ,"IF :"
    ,"INSERT ON"
    ,"NOT LIKE"
    "ORDER BY"
    ,"END;"
    ,"NVL("
    ,"REPLACE("
    ]
    header=[
    "AND"
    ,"AS"
    ,"BEFORE"
    ,"BEGIN"
    ,"BETWEEN"
    ,"BODY"
    ,"BOOLEAN"
    ,"CREATE"
    ,"CURSOR"
    ,"DECLARE"
    ,"ELSE"
    ,"END"
    ,"EXCEPTION"
    ,"EXIT"
    ,"FALSE"
    ,"FETCH"
    ,"FROM"
    ,"FUNCTION"
    ,"INSERT"
    ,"IF"
    ,"INSTR"
    ,"INTO"
    ,"IN"
    ,"IS"
    ,"LIKE"
    ,"LOOP"
    ,"NULL"
    ,"NUMBER"
    ,"ON"
    ,"OPEN"
    ,"OR"
    ,"PACKAGE"
    ,"PROCEDURE"
    ,"REPLACE"
    ,"SELECT"
    ,"DECODE"
    ,"SET"
    ,"SUBSTR"
    ,"DBMS_OUTPUT.PUT_LINE"
    ,"SYSDATE"
    ,"RETURN"
    ,"THEN"
    ,"TO_CHAR"
    ,"TO_DATE"
    ,"TRIGGER"
    ,"TRUE"
    ,"UNION"
    ,"UPDATE"
    ,"VALUES"
    ,"VARCHAR2"
    ,"WHEN"
    ,"WHENEVER"
    ,"WHERE"
    ,"WHILE"
    ]

    #    print mode
    if mode == "normal":
        range = "%"
    elif mode == "visual":

        range = "'<,'>"

    try:
        vim.command(range+"s/nvl (/nvl(/iegc")

        for i in header_match_exact:
            vim.command(range+"s/\s*"+i+"/ "+i.lower()+"/Iegc")

        for i in header:
            vim.command(range+"s/\(^\("+i+"\)\|\s"+i+"\)\(\s\|$\)/ "+i.lower()+" /Iegc")
            vim.command(range+"s/\(^\("+i+"\)\|\s"+i+"\)\((\)/ "+i.lower()+"(/Iegc")
            vim.command(range+"s/\(^\("+i+"\)\|\s"+i+"\)\(;\)/ "+i.lower()+";/Iegc")
    except:
        pass
vim.command( 'autocmd FileType sql map ,,u  :py SqlDecaps("normal")<cr>')
vim.command( 'autocmd FileType sql vmap ,,u :py SqlDecaps("visual")<cr>')
EOF
" vim:set et sts=4 sw=4:
