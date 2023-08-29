" Terminal library
" Last Change:  2009-10-15
" Maintainer:   Yukihiro Nakadaira <yukihiro.nakadaira@gmail.com>
" License:      This file is placed in the public domain.
" Reference:
"   Xterm Control Sequences
"   http://invisible-island.net/xterm/ctlseqs/ctlseqs.html

let s:save_cpo = &cpo
set cpo&vim

if !exists('term#outfile')
  let term#outfile = '/dev/stdout'
endif

let term#buf = ''

function! term#write(s)
  call writefile([a:s], g:term#outfile, 'b')
endfunction

" Output buffer
function! term#out()
  call term#write(g:term#buf)
  let g:term#buf = ''
endfunction

" Return buffer
function! term#str()
  let buf = g:term#buf
  let g:term#buf = ''
  return buf
endfunction

" Show text
function! term#text(s, ...)
  if len(a:000) != 0
    call call('term#attr', a:000)
  endif
  let g:term#buf .= a:s
endfunction

function! term#put(row, col, s, ...)
  call term#position(a:row, a:col)
  call term#attr()
  call call('term#text', [a:s] + a:000)
endfunction

" CSI P m m   Character Attributes (SGR)
"             P s = 0 → Normal (default)
"             P s = 1 → Bold
"             P s = 4 → Underlined
"             P s = 5 → Blink (appears as Bold)
"             P s = 7 → Inverse
"             P s = 8 → Invisible, i.e., hidden (VT300)
"             P s = 2 2 → Normal (neither bold nor faint)
"             P s = 2 4 → Not underlined
"             P s = 2 5 → Steady (not blinking)
"             P s = 2 7 → Positive (not inverse)
"             P s = 2 8 → Visible, i.e., not hidden (VT300)
"             P s = 3 0 → Set foreground color to Black
"             P s = 3 1 → Set foreground color to Red
"             P s = 3 2 → Set foreground color to Green
"             P s = 3 3 → Set foreground color to Yellow
"             P s = 3 4 → Set foreground color to Blue
"             P s = 3 5 → Set foreground color to Magenta
"             P s = 3 6 → Set foreground color to Cyan
"             P s = 3 7 → Set foreground color to White
"             P s = 3 9 → Set foreground color to default (original)
"             P s = 4 0 → Set background color to Black
"             P s = 4 1 → Set background color to Red
"             P s = 4 2 → Set background color to Green
"             P s = 4 3 → Set background color to Yellow
"             P s = 4 4 → Set background color to Blue
"             P s = 4 5 → Set background color to Magenta
"             P s = 4 6 → Set background color to Cyan
"             P s = 4 7 → Set background color to White
"             P s = 4 9 → Set background color to default (original).
"
" If 16-color support is compiled, the following apply. Assume that
" xterm’s resources are set so that the ISO color codes are the first 8
" of a set of 16. Then the aixterm colors are the bright versions of the
" ISO colors:
"
"             P s = 9 0 → Set foreground color to Black
"             P s = 9 1 → Set foreground color to Red
"             P s = 9 2 → Set foreground color to Green
"             P s = 9 3 → Set foreground color to Yellow
"             P s = 9 4 → Set foreground color to Blue
"             P s = 9 5 → Set foreground color to Magenta
"             P s = 9 6 → Set foreground color to Cyan
"             P s = 9 7 → Set foreground color to White
"             P s = 1 0 0 → Set background color to Black
"             P s = 1 0 1 → Set background color to Red
"             P s = 1 0 2 → Set background color to Green
"             P s = 1 0 3 → Set background color to Yellow
"             P s = 1 0 4 → Set background color to Blue
"             P s = 1 0 5 → Set background color to Magenta
"             P s = 1 0 6 → Set background color to Cyan
"             P s = 1 0 7 → Set background color to White
"
" If xterm is compiled with the 16-color support disabled, it supports
" the following, from rxvt:
"             P s = 1 0 0 → Set foreground and background color to default
"
" If 88- or 256-color support is compiled, the following apply.
"             P s = 3 8 ; 5 ; P s → Set foreground color to the second P s
"             P s = 4 8 ; 5 ; P s → Set background color to the second P s
function! term#attr(...)
  let m = (len(a:000) == 0 ? '0;39;49' : join(a:000, ';'))
  let g:term#buf .= printf("\e[%sm", m)
endfunction

" CSI P s @   Insert P s (Blank) Character(s) (default = 1) (ICH)
function! term#insert_blank(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%d@", a)
endfunction

" CSI P s A   Cursor Up P s Times (default = 1) (CUU)
function! term#up(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dA", a)
endfunction

" CSI P s B   Cursor Down P s Times (default = 1) (CUD)
function! term#down(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dB", a)
endfunction

" CSI P s C   Cursor Forward P s Times (default = 1) (CUF)
function! term#forward(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dC", a)
endfunction

" CSI P s D   Cursor Backward P s Times (default = 1) (CUB)
function! term#backward(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dD", a)
endfunction

" CSI P s E   Cursor Next Line P s Times (default = 1) (CNL)
function! term#next_line(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dE", a)
endfunction

" CSI P s F   Cursor Preceding Line P s Times (default = 1) (CPL)
function! term#preceding_line(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dF", a)
endfunction

" CSI P s G   Cursor Character Absolute [column] (default = [row,1]) (CHA)
" Cursor Character Absolute [column]
function! term#column(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dG", a)
endfunction

" CSI P s ; P s H   Cursor Position [row;column] (default = [1,1]) (CUP)
function! term#position(...)
  let a = get(a:000, 0, 1)
  let b = get(a:000, 1, 1)
  let g:term#buf .= printf("\e[%d;%dH", a, b)
endfunction

" CSI P s I   Cursor Forward Tabulation P s tab stops (default = 1) (CHT)
function! term#tabulation(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dI", a)
endfunction

" CSI P s J   Erase In Display (ED)
"             P s = 0 -> Erase Below (default)
"             P s = 1 -> Erase Above
"             P s = 2 -> Erase All
"             P s = 3 -> Erase Saved Lines (xterm)
function! term#erase_in_display(...)
  let a = get(a:000, 0, 0)
  let g:term#buf .= printf("\e[%dJ", a)
endfunction

" CSI P s K   Erase In Line (EL)
"             P s = 0 -> Erase to Right (default)
"             P s = 1 -> Erase to Left
"             P s = 2 -> Erase All
function! term#erase_in_line(...)
  let a = get(a:000, 0, 0)
  let g:term#buf .= printf("\e[%dK", a)
endfunction

" CSI P s L   Insert P s Line(s) (defualt = 1) (IL)
function! term#insert_line(...)
  let a = get(a:000, 0, 0)
  let g:term#buf .= printf("\e[%dL", a)
endfunction

" CSI P s M   Delete P s Line(s) (default = 1) (DL)
function! term#delete_line(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dM", a)
endfunction

" CSI P s P   Delete P s Character(s) (default = 1) (DCH)
function! term#delete_character(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dP", a)
endfunction

" CSI P s S   Scroll up P s lines (default = 1) (SU)
function! term#scroll_up(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dS", a)
endfunction

" CSI P s T   Scroll down P s lines (default = 1) (SD)
function! term#scroll_down(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dT", a)
endfunction

" CSI P s X   Erase P s Character(s) (default = 1) (ECH)
function! term#erase_character(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dX", a)
endfunction

" CSI P s Z   Cursor Backward Tabulation P s tab stops (default = 1) (CBT)
function! term#backward_tabulation(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dZ", a)
endfunction

" CSI P m d   Line Position Absolute [row] (default = [1,column]) (VPA)
function! term#line(...)
  let a = get(a:000, 0, 1)
  let g:term#buf .= printf("\e[%dd", a)
endfunction

" ESC 7       Save Cursor (DECSC)
function! term#save_cursor()
  let g:term#buf .= "\e7"
endfunction

" ESC 8       Restore Cursor (DECRC)
function! term#restore_cursor()
  let g:term#buf .= "\e8"
endfunction

function! term#clear()
  call term#attr()
  call term#erase_in_display(2)
endfunction

function! term#demo(...)
  let comvscom = get(a:000, 0, 0)

  try
    let barheight = 4
    let ball = {'x':&columns/2, 'y':&lines/2, 'xp':1, 'yp':1}
    let bar1 = {'x':7, 'y':&lines/2-barheight/2, 'yp':0}
    let bar2 = {'x':&columns - 6, 'y':&lines/2-barheight/2, 'yp':0}
    let score1 = 0
    let score2 = 0
    let com1 = 0
    let com1_wait = 0
    let com1_yp = 0
    let com2 = 0
    let com2_wait = 0
    let com2_yp = 0
    while 1
      let bar1.yp = 0
      let bar2.yp = 0

      let c = getchar(0)
      while type(c) != type(0) || c != 0
        if type(c) == type(0)
          let c = nr2char(c)
        endif
        if !comvscom
          if c == 'j' || c == "\<Down>"
            let bar1.yp = 1
          elseif c == 'k' || c == "\<Up>"
            let bar1.yp = -1
          endif
        endif
        let c = getchar(0)
      endwhile

      let com2 += 1
      if com2 % 3 != 0 && com2 % 5 != 0
        if ball.x < bar2.x
          let y = (ball.yp > 0 ? bar2.y : bar2.y + barheight)
          if ball.y < y && bar2.y >= 4
            let bar2.yp = -1
          elseif ball.y >= y && bar2.y + barheight <= &lines - 3
            let bar2.yp = 1
          endif
        endif
      endif
      if comvscom
        if ball.x > bar1.x
          if com1_wait > 0
            let com1_wait -= 1
            if com1_wait == 0
              let com1_yp = s:rand() % 10
            endif
          elseif com1_yp > 0
            let bar1.yp = ball.yp
            let com1_yp -= 1
          else
            let com1_wait = s:rand() % 5
          endif
        endif
      endif

      if bar1.y + bar1.yp >= 1 && bar1.y + bar1.yp + barheight - 1 <= &lines
        let bar1.y += bar1.yp
      endif
      if bar2.y + bar2.yp >= 1 && bar2.y + bar2.yp + barheight - 1 <= &lines
        let bar2.y += bar2.yp
      endif

      if ball.x + ball.xp < 1
        let ball.xp = -ball.xp
        let score2 += 1
      elseif ball.x + ball.xp > &columns
        let ball.xp = -ball.xp
        let score1 += 1
      elseif ball.x + ball.xp == bar1.x && ball.y >= bar1.y && ball.y <= bar1.y + barheight
        let ball.xp = -ball.xp
      elseif ball.x + ball.xp == bar2.x && ball.y >= bar2.y && ball.y <= bar2.y + barheight
        let ball.xp = -ball.xp
      endif
      let ball.x += ball.xp
      " add random
      if ball.x == &columns / 2 && localtime() % 2 == 0
        let ball.x += ball.xp
      endif
      if ball.y + ball.yp < 1
        let ball.yp = -ball.yp
      elseif ball.y + ball.yp > &lines
        let ball.yp = -ball.yp
      endif
      let ball.y += ball.yp

      call term#clear()
      let s = printf("%s: %d", comvscom ? "Com1" : "You", score1)
      call term#put(2, 4, s, 34)
      let s = printf("%s: %d", comvscom ? "Com2" : "Com", score2)
      call term#put(2, &columns - 4 - len(s), s, 31)
      for i in range(barheight)
        call term#put(bar1.y + i, bar1.x, ' ', 44)
      endfor
      for i in range(barheight)
        call term#put(bar2.y + i, bar2.x, ' ', 41)
      endfor
      call term#put(ball.y, ball.x, 'o', 32)
      call term#put(&lines, 1, 'Press CTRL-C to quit ...', 0)
      call term#out()
      sleep 50m
    endwhile
  catch /^Vim:Interrupt$/
  endtry

  " clear buffer
  call term#str()

  call term#attr()

  let cc = [41, 44, 42]
  let ss = ["(^^)/", "(^^)|"]
  for i in range(3)
    for s in ss
      call term#position(1, 1)
      for row in range(&lines)
        for col in range(&columns)
          call term#text(s[col%len(s)], cc[row%3])
        endfor
      endfor
      call term#out()
      sleep 300m
    endfor
  endfor
  call term#attr()
  for col in range(&columns)
    for row in range(&lines)
      let col2 = (row % 2 ? col : &columns - col - 1)
      call term#position(row + 1, col2 + 1)
      call term#text(' ')
    endfor
    call term#out()
    sleep 10m
  endfor

  redraw!
endfunction

let s:rand_next = localtime()
function! s:rand()
  let s:rand_next = s:rand_next * 1103515245 + 12345
  if s:rand_next < 0
    let s:rand_next -= 0x80000000
  endif
  return (s:rand_next / 65536) % 32768
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
