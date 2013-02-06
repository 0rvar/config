set nocompatible               " be iMproved
filetype off                   " required!


" Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
" Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
" Bundle 'tpope/vim-rails.git'
" vim-scripts repos
Bundle 'L9'
" Bundle 'FuzzyFinder'
Bundle 'kien/ctrlp.vim'

" non github repos
" Bundle 'wincent/Command-T'

filetype plugin indent on     " required!
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..

" easymotion config
let g:EasyMotion_leader_key = '§'

" sparkup
" c-r to expand html

""""""""""""""""""""""""""



" Indentation
set tabstop=2
set shiftwidth=2
set expandtab
" for command mode
nmap <S-Tab> <<
" for insert mode
imap <S-Tab> <Esc><<i
" Tab/shift-tab to indent/outdent in visual mode.
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" Keep selection when indenting/outdenting.
vnoremap > >gv
vnoremap < <gv

set nu " Line numbers
set scrolloff=5
set autoindent
set showmode
set showcmd
set hidden
set wildmenu " Autocompletion on commands
set wildmode=list:longest,full
set visualbell
set cursorline " Highlight current line
set ttyfast " Fast scrolling
set ruler

set backspace=indent,eol,start
set laststatus=2
set relativenumber

let mapleader = ","

" Match globally on lines
nnoremap / /\v 
vnoremap / /\v

" Match case insensitive
set ignorecase
set smartcase

set gdefault " Apply substitutions globally on lines

" Highlight search results
set incsearch
set showmatch
set hlsearch

nnoremap <leader><space> :noh<cr>
" nnoremap <tab> %
" vnoremap <tab> %

" handle long lines correctly
set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85

" Show invisible chars
set list
set listchars=tab:▸\ ,eol:¬

" Disable arrow keys, make jk behave sanely
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" Accidentally hitting ;
nnoremap ; :

" Save when window loses focus
au FocusLost * :wa


