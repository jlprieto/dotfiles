so ~/.vim/plugins.vim
set noerrorbells visualbell t_vb=		" Avoids beeping and visualbells when escaping and other errors
autocmd! bufwritepost .vimrc source %	" Automatic reloading of .vimrc
colorscheme badwolf
let g:badwolf_darkgutter = 1			"Make the gutters darker than the text


syntax enable							"enable syntax processing
set number								"set line numbers
:set number relativenumber
set tabstop=4							"number of visual spaces per tab
set softtabstop=4						"number of spaces in tab when editing
set showcmd								"show command in bottom bar
set cursorline							"highlight current line
set showmatch							"highlight matching [{()}] 

"Enable code folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za						" remap za to space to be able to fold with space bar

" Better copy / paste
set pastetoggle=<F2>
set clipboard=unnamed

" Mouse and backspace
set mouse=a								" on OSX press ALT and click
set bs=2								" Make backspace behave normal

" NERDtree Settings
let NERDTreeShowHidden=1


:imap jk <ESC>							" remap ESC key to jk
map <C-o> :NERDTreeToggle<CR>

" Move faster between splits with control key
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Settings for vim-powerline
set laststatus=2
set guifont=Inconsolata\ for\ Powerline:h15
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set fillchars+=stl:\ ,stlnc:\

" Better Python IDE stuff
" Proper PEP8 indentation
au BufNewFile,BufRead *.py:
	\ set tabstop=4
	\ set softtabstop=4
	\ set shiftwidth=4
	\ set textwidth=79
	\ set expandtab
	\ set autoindent
	\ set fileformat=unix
	\ set nowrap " don't automatically wrap on load
	\ set fo-=t " don't automatically wrap text when typing
	\ set colorcolumn=80

highlight ColorColumn ctermbg=233
:nnoremap <buffer> H :<C-u>execute "!pydoc3 " . expand("<cword>")<CR>	" execute pytdoc3 to see python docstrings
