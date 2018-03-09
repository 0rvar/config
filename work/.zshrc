# Oh-my-zsh preload config
export ZSH=$HOME/.oh-my-zsh

## No theme - specify ourselves in this file
ZSH_THEME="simple"

## Display '...' when waiting for completion to complete
COMPLETION_WAITING_DOTS="true"

## Set omz plugins
plugins=(
  git           # git aliases, like gst, ga, gc (see alias | grep git)
  brew          # homebrew completion
  npm           # npm completion
  bundler
  rbenv

  extract       # `extract` command for any archive type

  jump          # `mark`, `marks`, `jump` commands, like wd
  z             # like autojump, but takes several regexes and doesn't require autojump installed

  per-directory-history
  zsh-syntax-highlighting
)

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
setopt inc_append_history
setopt share_history

## Functions

# custom git aliases
alias glr='git pull --rebase'
alias glf='git pull --ff-only'

function s() {
  rg -C 10 -M 200 -p "$@" | less -r
}

function o() {
  open "$@" &>/dev/null &!
}

# Percol functions
function ppgrep() {
  if [[ $1 == "" ]]; then
    PERCOL=percol
  else
    PERCOL="percol --query $1"
  fi
  ps aux | eval $PERCOL | awk '{ print $2 }'
}
function ppkill() {
  if [[ $1 =~ "^-" ]]; then
    QUERY=""            # options only
  else
    QUERY=$1            # with a query
    [[ $# > 0 ]] && shift
  fi
  ppgrep $QUERY | xargs kill $*
}
function exists { which $1 &> /dev/null }
if exists percol; then
  function percol_select_history() {
    local tac
    exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
    BUFFER=$(fc -l -n 1 | eval $tac | percol --query "$LBUFFER")
    CURSOR=$#BUFFER         # move cursor
    zle -R -c               # refresh
  }

  zle -N percol_select_history
  bindkey '^R' percol_select_history

  function pco() {
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git checkout
  }

  function pcor() {
    a=$(mktemp)
    b=$(mktemp)
    git for-each-ref --sort=-committerdate refs/remotes/origin --format=%\(refname:short\) | grep -v HEAD | sed -e "s/^origin\///" > $a \
      && git for-each-ref --sort=-committerdate refs/heads --format=%\(refname:short\) > $b \
      && grep -Fvxf $b $a | percol | xargs -i git checkout -t origin/{}
  }

  function pme() {
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git merge
  }
fi

## Run after-config if exists
if [ -f "$HOME/.zshrc.after" ]; then
  source $HOME/.zshrc.after
fi
