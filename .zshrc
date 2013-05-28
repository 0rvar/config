ZSH=$HOME/.oh-my-zsh
ZSH_THEME="bira"
HISTORY_BASE=$ZSH/.directory_history

COMPLETION_WAITING_DOTS="true"

plugins=(git bundler extract gem nyan)
source $ZSH/oh-my-zsh.sh

export EDITOR=vim

# ZSH Customization
unsetopt correctall 

# Box-specific configuration
if [ -f ".box" ]; then
  source .box
fi

# Functions
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

