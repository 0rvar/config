# Short path
set -xg theme_short_path yes

# bin dir
set -xg PATH $HOME/.dotfiles/work/.bin $PATH
set -xg PATH $HOME/.dotfiles/.bin $PATH

# Use new gnu utils
set -xg PATH /usr/local/opt/findutils/libexec/gnubin $PATH

# Use python installs (pipenv etc)
set -xg PATH $HOME/Library/Python/3.6/bin $PATH 

set -xg LANG en_US.UTF-8
set -xg LC_ALL en_US.UTF-8

set -xg LESSOPEN "| src-hilite-lesspipe.sh %s"
set -xg LESS " -R "

set -xg MINIUM_DEVELOPER_BUILD 1
