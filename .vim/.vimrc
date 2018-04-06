set nocompatible					" required by Vundle 
filetype off
set rtp+=~/.vim/bundle/Vundle.vim	" set the path for Vundle
call vundle#begin()					" start Vundle
Plugin 'VundleVim/Vundle.vim'		" let Vundle manage itself
call vundle#end()            " required
filetype plugin indent on    " required


colorscheme badwolf		"setup colorschem located in .vim/colors
let g:badwolf_darkgutter = 1 "Make the gutters darker than the text


syntax enable			"enable syntax processing
set number				"set line numbers
set tabstop=4			"number of visual spaces per tab
set softtabstop=4		"number of spaces in tab when editing
set showcmd				"show command in bottom bar
set cursorline			"highlight current line
set showmatch			"highlight matching [{()}] 
