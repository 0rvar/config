ZSH=$HOME/.oh-my-zsh
ZSH_THEME="bira"
HISTORY_BASE=$ZSH/.directory_history

COMPLETION_WAITING_DOTS="true"

plugins=(git bundler extract gem)
source $ZSH/oh-my-zsh.sh

export PATH=$HOME/.bin:$PATH
export EDITOR=vim

# ZSH Customization
#I don't like this feature. I think no one does. It corrects you, when you are trying to create new files, for example.
unsetopt correctall 


# Ruby
export RBENV_ROOT="${HOME}/.rbenv"
if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi

# Golang
export GOROOT=$HOME/apps/go
if [ -d "${GOROOT}" ]; then
  export PATH=$PATH:$GOROOT/bin
  export GOPATH=$HOME/develop/go
fi

# tomcat
export CATALINA_HOME="${HOME}/apps/tomcat"


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

