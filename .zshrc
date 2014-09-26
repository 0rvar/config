# Oh-my-zsh preload config
ZSH=$HOME/.oh-my-zsh

## Set theme
ZSH_THEME="bira"

## Display '...' when waiting for completion to complete
COMPLETION_WAITING_DOTS="true"

## Set omz plugins
plugins=(git extract nyan web-search rbenv bundler jump)

## Run before-config if exists
if [ -f "$HOME/.zshrc.before" ]; then
  source $HOME/.zshrc.before
fi


# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh


# Settings

## Text editor
export EDITOR=sublime-text

## ZSH Customization
unsetopt correctall
setopt inc_append_history
setopt share_history

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
alias o='xdg-open'
alias upg='sudo apt-get update && sudo apt-get upgrade'

alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'


## Run after-config if exists
if [ -f "$HOME/.zshrc.after" ]; then
  source $HOME/.zshrc.after
fi
