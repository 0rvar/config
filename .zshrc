# Oh-my-zsh preload config
ZSH=$HOME/.oh-my-zsh

## Set theme
ZSH_THEME="bira"

## Set history directory
HISTORY_BASE=$ZSH/.directory_history

## Display '...' when waiting for completion to complete
COMPLETION_WAITING_DOTS="true"

## Set omz plugins
plugins=(git extract gem bundler nyan lol web-search)

## Run before-config if exists
if [ -f "$HOME/.zshrc.before" ]; then
  source $HOME/.zshrc.before
fi


# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh


# Settings

## Text editor
export EDITOR=vim

## ZSH Customization
unsetopt correctall 

## Functions
function ft() {
  P=.
  EXT="rb"

  if [[ $# -ge 1 ]]; then
    P="$1"

    if [[ $# -ge 2 ]]; then
      EXT="$2"
    fi
  fi

  find $P | egrep "(.*)\.$EXT$"
}

# git pull rebase
alias glr='git pull --rebase'

## Run after-config if exists
if [ -f "$HOME/.zshrc.after" ]; then
  source $HOME/.zshrc.after
fi
