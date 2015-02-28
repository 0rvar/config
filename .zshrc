# Oh-my-zsh preload config
ZSH=$HOME/.oh-my-zsh

## No theme - specify ourselves in this file
ZSH_THEME=""

## Display '...' when waiting for completion to complete
COMPLETION_WAITING_DOTS="true"

## Set omz plugins
plugins=(
    git           # git aliases, like gst, ga, gc (see alias | grep git)
    rbenv         # Set up rbenv (if ~/.rbenv exists)
    bundler       # bundle aliases like bi, be. dynamic bundle aliases like rails, rake, cap

    extract       # `extract` command for any archive type
    web-search    # `google`, `ddg`, `youtube` search for terminal

    jump          # `mark`, `marks`, `jump` commands, like wd
    autojump      # Learns common directories, provides shortcuts like `j dir` to go there
    z             # like autojump, but takes several regexes and doesn't require autojump installed
    dircycle      # Nondestructive pushd/popd with ctrl+shift+{left,right}
    )
# Maybe try fasd? git-extras? git-flow?

## Run before-config if exists
if [ -f "$HOME/.zshrc.before" ]; then
  source $HOME/.zshrc.before
fi


# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh


# Theme
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'
local git_branch='$(git_prompt_info)%{$reset_color%}'

PROMPT="╭─${user_host} ${current_dir} ${git_branch}
╰─%B$%b "
RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"


# Settings

## Text editor
export EDITOR=vim

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
alias upg='sudo apt-get update && sudo apt-get dist-upgrade -yy'

alias cbcopy='xsel --clipboard --input'
alias cbpaste='xsel --clipboard --output'

alias upgrade-rust='curl -s https://static.rust-lang.org/rustup.sh | sudo sh'

haste() {
  a=$(cat)
  curl -X POST -s -d "$a" http://hastebin.com/documents | awk -F '"' '{print "http://hastebin.com/"$4}'
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
fi

## Run after-config if exists
if [ -f "$HOME/.zshrc.after" ]; then
  source $HOME/.zshrc.after
fi
