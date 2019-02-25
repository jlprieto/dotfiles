#! /bin/bash

VERSION="2018_04"
LOG_FILE=~/.dotfile_log

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
# backupFile <file> [<replace_re>]
# make a backup copy of a file we're going to modify.
#
# optionally strip all lines after the first line
# containing regexp replace_re, if specified
backupFile(){
    local f="$1"
    local f_backup="${f}.backup"
    local replace_re="$2"
    local line

    if [[ -e "$f" ]] ; then
        # target file exists, back it up
        log "backing up $f ot $f_backup"
        if [[ -z "$replace_re" ]] ; then
            cp "$f" "$f_backup"
        else
            mv "$f" "$f_backup"
            # copy lines only up to matching pattern from backup
            (while true ; do 
                read -r line
                if [[ $? -ne 0 ]] ; then
                    #read failed, end of file
                    break
                fi
                if [[ "$line" =~ "$replace_re" ]] ; then
                    # matched, stop copying
                    break
                fi
                # copy line and continue
                echo "$line" >> "$f"
            done) < "f_backup"
        fi
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
        # ugh even throws error if 'upgrading' to the same version
        # hack around that :(
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
if [ ! -d $HOME/.dotfiles ]; then
		msg "There is NO .dotfiles folder. Clone .dotfiles from https://github.com/jlprieto/dotfiles.git"
		exit 1
fi

####
# Start by setting up Vim
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
echo

if [ "$GIT_USER" != "" ]; then
		git config user.email $GIT_USER
else
		git config user.email 3220204+jlprieto@users.noreply.github.com
fi
