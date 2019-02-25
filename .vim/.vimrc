so ~/.vim/plugins.vim
autocmd! bufwritepost .vimrc source %	" Automatic reloading of .vimrc
colorscheme badwolf
let g:badwolf_darkgutter = 1			"Make the gutters darker than the text


syntax enable							"enable syntax processing
set number								"set line numbers
set tabstop=4							"number of visual spaces per tab
set softtabstop=4						"number of spaces in tab when editing
set showcmd								"show command in bottom bar
set cursorline							"highlight current line
set showmatch							"highlight matching [{()}] 
:set number relativenumber



" Better copy / paste
set pastetoggle=<F2>
set clipboard=unnamed

" Mouse and backspace
set mouse=a								" on OSX press ALT and click
set bs=2								" Make backspace behave normal


:imap jk <ESC>
map <C-o> :NERDTreeToggle<CR>
