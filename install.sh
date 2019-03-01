#! /bin/bash

VERSION="2019_01"
LOG_FILE=$HOME/.dotfile_log

###
# msg [args]
# print a string and highlight to distinguish from other install spew.
msg() {
    echo -en '\xE2\x9A\xBD'
    echo -en '\033[32m'
    echo "$@"
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
    local dummy
    read -p '[Return] to continue> ' dummy
}

###
# backupFile <file> 
# make a backup copy of a file we're going to modify.
backupFile(){
    local f="$1"
    local f_backup="${f}.backup"

	if [[ -e "$f_backup" ]] ; then
		# a backup already exists
		break
	fi
    if [[ -e "$f" ]] ; then
        # target file exists, back it up
        log "backing up $f to $f_backup"
		cp "$f" "$f_backup"
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
    if brew ls --versions "$1" >/dv/null; then
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

writeToBashProfile(){
		local str="$1"
		echo "$str" >> $HOME/.bash_profile
}

############
# ALL SETUP STARTS HERE

rm -f "$LOG_FILE"
log "I'm going to start setting up this machine."

####
# Start by backing up .bash_profile
msg "Let's start by backing the original .bash_profile and .bash_rc"
backupFile ~/.bash_profile 
backupFile ~/.bashrc 
writeToBashProfile "source $HOME/.bashrc"

####
# Check if I'm in a MacOS or in a Linux
OS_NAME=""
case "$OSTYPE" in
  darwin*)  OS_NAME="OSX" ;;
  linux*)   OS_NAME="LINUX" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac
msg "Looks like we're setting up a $OS_NAME"

####
# Check that we actually cloned .dotfiles 
if [[ ! -d $HOME/.dotfiles ]]; then
		msg "There is NO .dotfiles folder. Clone .dotfiles from https://github.com/jlprieto/dotfiles.git"
		exit 1
else
		msg "The .dotfiles folder seems to be in place. Let's get started"
fi

####
# Start by setting up Vim
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
	msg "XCode"
	msg "If XCode is already installed there will be an error message that can be savely ignored"
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
	sudo add-apt-repository universe
	sudo apt-get update
	sudo apt install python3-setuptools
	sudo apt install python3-pip
fi
testReturnValue "pip3"

if [[ "$OS_NAME" == "OSX" ]]; then
	msg "Homebrew Python3"
	brewInstallOrUpgrade python
	testReturnValue "Homebrew Python3"

	msg "Homebrew Python2"
	brewInstallOrUpgrade python@2
	testReturnValue "Homebrew Python2"

	msg "gcc"
	brewInstallOrUpgrade gcc
	testReturnValue "gcc"

	msg "cmake"
	brewInstallOrUpgrade cmake
	testReturnValue "cmake"

	#needed for matplotlib
	msg "freetype"
	brewInstallOrUpgrade freetype
	testReturnValue "freetype"

	msg "hdf5"
	brewInstallOrUpgrade hdf5
	testReturnValue "hdf5"
fi	

msg "virtualenvwrapper"
pip3 install virtualenvwrapper
testReturnValue "virtualenvwrapper"

msg "path_to_virtualenvwrapper"
writeToBashProfile "export WORKON_HOME=$HOME/.venvs" 
if [ "$OS_NAME" == "LINUX" ]; then
	writeToBashProfile "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" 
	writeToBashProfile "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv"
	writeToBashProfile "source $HOME/.local/bin/virtualenvwrapper.sh"
fi
if [[ "$OS_NAME" == "OSX" ]]; then
	writeToBashProfile "export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3"
	writeToBashProfile "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv"
	writeToBashProfile "source /usr/local/bin/virtualenvwrapper.sh"
fi
source $HOME/.bash_profile
testReturnValue "path_to_virtualenvwrapper"

msg "py3_virtualenv"
if [ "$OS_NAME" == "LINUX" ]; then
	mkvirtualenv --python=/usr/bin/python3 py3
fi
if [[ "OS_NAME" == "OSX" ]]; then
	mkvirtualenv --python=/usr/local/bin/python py3
fi
writeToBashProfile "workon py3"
source $HOME/.bash_profile
testReturnValue "py3_virtualenv"
