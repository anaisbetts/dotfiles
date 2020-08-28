filetype off

set nocp
set hidden
filetype plugin on

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Don't use Ex mode, use Q for formatting
map Q gq

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

set autoindent		" always set autoindenting on

" Set up tabbing through tags a bit easier
nm <C-Tab> :tn<CR>
nm <C-S-Tab> :tp<CR>

set scrolloff=3
set ruler
set shortmess=atI

"Sets how many lines of history VIM har to remember
set history=400

"Set mapleader
let mapleader = ","
let g:mapleader = ","
let maplocalleader = ","
let g:maplocalleader = ","

" Set git ft to do diffs
let g:git_diff_spawn_mode = 1

" XAML files are Xml, really!
autocmd BufNewFile,BufRead *.xaml set ft=xml

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_running")
  set guioptions-=T
  let psc_style='cool'
  colorscheme ps_color
else
  set background=dark
  colorscheme koehler
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fileformats
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Favorite filetypes
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM userinterface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Set 7 lines to the curors - when moving vertical..
set so=7

"Turn on WiLd menu
set wildmenu

"The commandbar is 2 high
set cmdheight=1

"Do not redraw, when running macros.. lazyredraw
set lz

"Change buffer - without saving
set hid

"Set backspace
set backspace=eol,start,indent

"Bbackspace and cursor keys wrap to
set whichwrap+=<,>,h,l

"Set magic on
set magic

"No sound on errors.
set noerrorbells
set novisualbell
set t_vb=

"show matching bracets
set showmatch

"How many tenths of a second to blink
set mat=2

"Highlight search things
set hlsearch

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around and tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Map space to / and c-space to ?
map <c-space> /

"Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files and backups
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Turn backup off
"set nobackup
"set nowb
set noswapfile
set noar


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Folding
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set fen
set fdl=0


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set smarttab autoindent
set lbr
set tw=120

""""""""""""""""""""""""""""""
" => Indent
""""""""""""""""""""""""""""""
"Auto indent
set ai

"Smart indet
set si

"C-style indeting
set cindent

"Wrap lines
set wrap

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => MISC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Close the damn preview window
noremap <Leader>z :pc!<cr>

" Move to next, prev buffer
nnoremap <c-n> :next<Enter>
nnoremap <c-p> :prev<Enter>
set confirm

autocmd Filetype ruby setlocal ts=2 sw=2 et

" ,f launches Ack search
map <leader>f :Ack<space>
