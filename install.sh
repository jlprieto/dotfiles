#! /bin/bash

VERSION="2019_01"
LOG_FILE=$HOME/.dotfile_log

###
# msg [args]
# print a string and highlight to distinguish from other install spew.
msg() {
    echo -en '\xE2\x9A\xBD'
    echo -en '\033[32m'
    echo ": $@"
    echo -en '\033[39m'
}

###
# log [args]
# print a string to the console and to the log
log() {
    msg "$@"
    echo "$@" >> "$LOG_FILE"
}

###
# confirm
# wait for user to press a key
confirm() {
    local aux
    read -p '[Return] to continue> ' aux
}

###
# backupFile <file> 
# make a backup copy of a file we're going to modify.
backupFile(){
    local f="$1"
    local f_backup="${f}.backup"

	if [[ -e "$f_backup" ]] ; then
		# a backup already exists
		return	
	fi
    if [[ -e "$f" ]] ; then
        # target file exists, back it up
        log "backing up $f to $f_backup"
		mv "$f" "$f_backup"
    else
        # target file doesn't exist, no problem
        log "$f not found, not creating backup"
    fi
}

###
# brewInstallOrUpgrade <pkg>
# gracefully handle case of installing something
# that's already installed
function brewInstallOrUpgrade {
	local aux=$(brew ls --versions "$1")
	echo "${aux}"
    if [[ ! -z "$aux" ]]; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$1" || true
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1" 
    fi
}

###
# testReturnValue <name>
# log success/failure of an installation step
# depending on the value of $?
testReturnValue () {
    local status=$?
    local install_target=$1

    if [[ $status -eq 0 ]] ; then
        log "Successfully installed $install_target"
    else
        log "Failed to install ${install_target}; status=${status}. Exiting."
        exit $status
    fi
}

writeToEnvProfile(){
		local str="$1"
		echo "$str" >> $HOME/.zshenv
}

############
# ALL SETUP STARTS HERE

# Check that we actually cloned .dotfiles 
if [[ ! -d $HOME/.dotfiles ]]; then
		msg "There is NO .dotfiles folder. Clone .dotfiles from https://github.com/jlprieto/dotfiles.git"
		exit 1
else
		msg "The .dotfiles folder seems to be in place. Let's get started"
fi

####
# Check if I'm in a MacOS or in a Linux
OS_NAME=""
case "$OSTYPE" in
  darwin*)  OS_NAME="OSX" ;;
  linux*)   OS_NAME="LINUX" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

rm -f "$LOG_FILE"
log "I'm going to start setting up this $OS_NAME machine."
if [[ -e $HOME/.zshenv ]]; then
	rm -f $HOME/.zshenv
fi

####
# Set the shell
# First install zsh shell
zsh --version
if [[ $? -ne 0 ]]; then
	if [[ "$OS_NAME" == "OSX" ]]; then
		msg "zsh"
		brew install zsh zsh-completions
		testReturnValue "zsh"
		chsh -s $(which zsh)
	fi
	if [[ "$OS_NAME" == "LINUX" ]]; then
		msg "zsh"
		sudo add-apt-repository universe
		sudo apt-get update
		sudo apt-get install zsh
		testReturnValue "zsh"
		sudo chsh -s $(which zsh) $USER
	fi
fi

# Install oh-my-zsh to get all the aliases and other goodies
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# now it's time to backup any .zshrc or .zshrc_profile files
msg "Let's backup any old .zshrc files"
backupFile $HOME/.zshrc

# link .zshrc
msg "Linking to .dotfiles for zsh"
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

####
# Setup Vim
msg "Linking to .dotfiles for vim"
if [ ! -e $HOME/.vim ]; then 
		ln -s $HOME/.dotfiles/.vim $HOME/.vim
fi

if [ ! -e $HOME/.vimrc ]; then
		ln -s $HOME/.dotfiles/.vim/.vimrc $HOME/.vimrc
fi

####
# Setup git stuff
msg "Enter email for git commits [or leave blank for default gitHub email]"
read -p '[3220204+jlprieto@users.noreply.github.com]> ' -r GIT_USER

if [ "$GIT_USER" != "" ]; then
		git config user.email $GIT_USER
else
		git config user.email 3220204+jlprieto@users.noreply.github.com
fi

#####
# Specific things for MACOS
if [[ "$OS_NAME" == "OSX" ]]; then
	msg "XCode: If XCode is already installed there will be an error message that can be savely ignored"
	xcode-select --install 
	confirm
	testReturnValue "XCode"

	if [[ -x /usr/local/bin/brew ]]; then
		msg "Homebrew already installed, updating"
		brew update
	else
		msg "Installing Homebrew"
		confirm
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
		source $HOME/.bash_profile
		testReturnValue "Homebrew"
	fi
fi

#####
# Setup python stuff
if [[ -n "$VIRTUAL_ENV" ]]; then
	msg "You're on a virtual environment. Make sure you deactivate it before continuing"
	exit 1
fi

msg "pip3"
if [ "$OS_NAME" == "LINUX" ]; then
	sudo apt install python3-setuptools
	sudo apt install python3-pip
fi
testReturnValue "pip3"

if [[ "$OS_NAME" == "OSX" ]]; then
	msg "Homebrew Python3"
	brewInstallOrUpgrade python
	testReturnValue "Homebrew Python3"
#
#	msg "Homebrew Python2"
#	brewInstallOrUpgrade python@2
#	testReturnValue "Homebrew Python2"
#
#	msg "gcc"
#	brewInstallOrUpgrade gcc
#	testReturnValue "gcc"
#
#	msg "cmake"
#	brewInstallOrUpgrade cmake
#	testReturnValue "cmake"
#
#	#needed for matplotlib
#	msg "freetype"
#	brewInstallOrUpgrade freetype
#	testReturnValue "freetype"
#
#	msg "hdf5"
#	brewInstallOrUpgrade hdf5
#	testReturnValue "hdf5"
fi	

msg "virtualenvwrapper"
pip3 install virtualenvwrapper
testReturnValue "virtualenvwrapper"

msg "path_to_virtualenvwrapper"
writeToEnvProfile "export WORKON_HOME=$HOME/.venv" 
if [ "$OS_NAME" == "LINUX" ]; then
	writeToEnvProfile "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" 
	writeToEnvProfile "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv"
	writeToEnvProfile "source $HOME/.local/bin/virtualenvwrapper.sh"
fi
if [[ "$OS_NAME" == "OSX" ]]; then
	writeToEnvProfile "export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3"
	writeToEnvProfile "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv"
	writeToEnvProfile "source /usr/local/bin/virtualenvwrapper.sh"
fi
testReturnValue "path_to_virtualenvwrapper"

msg "python_virtualenvironments"
if [ "$OS_NAME" == "LINUX" ]; then
	mkvirtualenv --python=/usr/bin/python3 py3
	mkvirtualenv --python=/usr/bin/python2 py2
fi
if [[ "OS_NAME" == "OSX" ]]; then
	mkvirtualenv --python=/usr/local/bin/python3 py3
	mkvirtualenv --python=/usr/local/bin/python py2
fi
testReturnValue "python_virtualenvironments"
source $HOME/.zshenv

# py2 packages
workon py2
msg "future"
pip install future
testReturnValue "future"

msg "ipdb"
pip install ipdb
testReturnValue "ipdb"

msg "numpy"
pip install numpy
testReturnValue "numpy"

msg "scipy"
pip install scipy
testReturnValue "scipy"

msg "matplotlib"
pip install matplotlib
testReturnValue "matplotlib"

msg "imageio"
pip install imageio
testReturnValue "imageio"

msg "sklearn"
pip install sklearn
testReturnValue "sklearn"

msg "pandas"
pip install pandas
testReturnValue "pandas"

msg "jupyter"
pip install jupyter
testReturnValue "jupyter"

msg "h5py"
pip install h5py
testReturnValue "h5py"

msg "pyserial"
pip install pyserial
testReturnValue "pyserial"

msg "lxml"
pip install lxml
testReturnValue "lxml"

msg "beautifulsoup4"
pip install beautifulsoup4
testReturnValue "beautifulsoup4"

# py3 packages
workon py3
msg "future"
pip install future
testReturnValue "future"

msg "ipdb"
pip install ipdb
testReturnValue "ipdb"

msg "numpy"
pip install numpy
testReturnValue "numpy"

msg "scipy"
pip install scipy
testReturnValue "scipy"

msg "matplotlib"
pip install matplotlib
testReturnValue "matplotlib"

msg "imageio"
pip install imageio
testReturnValue "imageio"

msg "sklearn"
pip install sklearn
testReturnValue "sklearn"

msg "pandas"
pip install pandas
testReturnValue "pandas"

msg "jupyter"
pip install jupyter
testReturnValue "jupyter"

msg "h5py"
pip install h5py
testReturnValue "h5py"

msg "pyserial"
pip install pyserial
testReturnValue "pyserial"

msg "lxml"
pip install lxml
testReturnValue "lxml"

msg "beautifulsoup4"
pip install beautifulsoup4
testReturnValue "beautifulsoup4"
# Done with setting up python virtualenv's
deactivate

msg "Looks like we're done."
msg "To make sure all files are properly sourced leave this session and start a new one"
