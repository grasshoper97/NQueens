let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
inoremap <silent> <Plug>NERDCommenterInsert  <BS>:call NERDComment('i', "insert")
nmap  :cnext
nmap  :cprev
nmap ,q :q
nmap ,a :csadd cscope.out
nmap ,s :cs find s =expand("<cword>")
nmap ,g :cs find g =expand("<cword>")
nmap ,c :cs find c =expand("<cword>")
nmap ,t :cs find t =expand("<cword>")
nmap ,e :cs find e =expand("<cword>")
nmap ,f :cs find f =expand("<cfile>")
nmap ,i :cs find i =expand("<cfile>")
nmap ,d :cs find d =expand("<cword>")
nmap ,cc <Plug>NERDCommenterComment
xmap ,cc <Plug>NERDCommenterComment
nmap ,c  <Plug>NERDCommenterToggle
xmap ,c  <Plug>NERDCommenterToggle
nmap ,cm <Plug>NERDCommenterMinimal
xmap ,cm <Plug>NERDCommenterMinimal
nmap ,cn <Plug>NERDCommenterNested
xmap ,cn <Plug>NERDCommenterNested
nmap ,c$ <Plug>NERDCommenterToEOL
nmap ,ci <Plug>NERDCommenterInvert
xmap ,ci <Plug>NERDCommenterInvert
nmap ,cs <Plug>NERDCommenterSexy
xmap ,cs <Plug>NERDCommenterSexy
nmap ,cy <Plug>NERDCommenterYank
xmap ,cy <Plug>NERDCommenterYank
nmap ,cA <Plug>NERDCommenterAppend
nmap ,cl <Plug>NERDCommenterAlignLeft
xmap ,cl <Plug>NERDCommenterAlignLeft
nmap ,cb <Plug>NERDCommenterAlignBoth
xmap ,cb <Plug>NERDCommenterAlignBoth
nmap ,cu <Plug>NERDCommenterUncomment
xmap ,cu <Plug>NERDCommenterUncomment
nmap ,ca <Plug>NERDCommenterAltDelims
vmap ,,    
nmap gx <Plug>NetrwBrowseX
vmap gx <Plug>NetrwBrowseXVis
nmap wm :WMToggle
nnoremap <silent> <Plug>NERDCommenterComment :call NERDComment("n", "Comment")
xnoremap <silent> <Plug>NERDCommenterComment :call NERDComment("x", "Comment")
nnoremap <silent> <Plug>NERDCommenterToggle :call NERDComment("n", "Toggle")
xnoremap <silent> <Plug>NERDCommenterToggle :call NERDComment("x", "Toggle")
nnoremap <silent> <Plug>NERDCommenterMinimal :call NERDComment("n", "Minimal")
xnoremap <silent> <Plug>NERDCommenterMinimal :call NERDComment("x", "Minimal")
nnoremap <silent> <Plug>NERDCommenterNested :call NERDComment("n", "Nested")
xnoremap <silent> <Plug>NERDCommenterNested :call NERDComment("x", "Nested")
nnoremap <silent> <Plug>NERDCommenterToEOL :call NERDComment("n", "ToEOL")
nnoremap <silent> <Plug>NERDCommenterInvert :call NERDComment("n", "Invert")
xnoremap <silent> <Plug>NERDCommenterInvert :call NERDComment("x", "Invert")
nnoremap <silent> <Plug>NERDCommenterSexy :call NERDComment("n", "Sexy")
xnoremap <silent> <Plug>NERDCommenterSexy :call NERDComment("x", "Sexy")
nnoremap <silent> <Plug>NERDCommenterYank :call NERDComment("n", "Yank")
xnoremap <silent> <Plug>NERDCommenterYank :call NERDComment("x", "Yank")
nnoremap <silent> <Plug>NERDCommenterAppend :call NERDComment("n", "Append")
nnoremap <silent> <Plug>NERDCommenterAlignLeft :call NERDComment("n", "AlignLeft")
xnoremap <silent> <Plug>NERDCommenterAlignLeft :call NERDComment("x", "AlignLeft")
nnoremap <silent> <Plug>NERDCommenterAlignBoth :call NERDComment("n", "AlignBoth")
xnoremap <silent> <Plug>NERDCommenterAlignBoth :call NERDComment("x", "AlignBoth")
nnoremap <silent> <Plug>NERDCommenterUncomment :call NERDComment("n", "Uncomment")
xnoremap <silent> <Plug>NERDCommenterUncomment :call NERDComment("x", "Uncomment")
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#BrowseX(expand((exists("g:netrw_gx")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())
vnoremap <silent> <Plug>NetrwBrowseXVis :call netrw#BrowseXVis()
imap ,,    
cmap ,,    
let &cpo=s:cpo_save
unlet s:cpo_save
set autochdir
set autoindent
set background=dark
set backspace=indent,eol,start
set cscopequickfix=s-,g-,c-,d-,i-,t-,e-
set fileencodings=ucs-bom,utf-8,default,latin1
set helplang=en
set history=1000
set hlsearch
set incsearch
set laststatus=2
set printoptions=paper:a4
set ruler
set runtimepath=~/.vim,~/.vim/bundle/Vundle.vim,~/.vim/bundle/nerdcommenter,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim74,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after,~/.vim/bundle/Vundle.vim,~/.vim/bundle/Vundle.vim/after,~/.vim/bundle/nerdcommenter/after
set shiftwidth=4
set showmatch
set smartindent
set statusline=%F%m%r%h%w%=\ [ft=%Y]\ %{\"[fenc=\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\"+\":\"\").\"]\"}\ [ff=%{&ff}]\ [asc=%03.3b]\ [hex=%02.2B]\ [pos=%04l,%04v][%p%%]\ [len=%L]
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.class
set tabstop=4
set tags=./tags
set visualbell
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/test/NQueen/CheckOne_Datafile_compare
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +0 ~/test/NQueen/CheckOne_Datafile_compare/java_v1_heavy/CountTask.java
argglobal
silent! argdel *
argadd readme.txt
edit ~/test/NQueen/CheckOne_Datafile_compare/java_v1_heavy/CountTask.java
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=j1
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=//%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
set cursorcolumn
setlocal cursorcolumn
set cursorline
setlocal cursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != 'java'
setlocal filetype=java
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
set foldlevel=100
setlocal foldlevel=100
setlocal foldmarker={{{,}}}
set foldmethod=syntax
setlocal foldmethod=syntax
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal indentexpr=GetJavaIndent()
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e,0=extends,0=implements
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal smartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.java
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'java'
setlocal syntax=java
endif
setlocal tabstop=4
setlocal tagcase=
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
let s:l = 99 - ((29 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
99
normal! 09|
lcd ~/test/NQueen/CheckOne_Datafile_compare
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
