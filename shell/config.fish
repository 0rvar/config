set DIR (dirname (realpath (status --current-filename)))
set CONFIG_ROOT (realpath $DIR/..)

source $DIR/env.fish

set -xg LANG en_US.UTF-8
set -xg LC_ALL en_US.UTF-8

# Editor etc
set -xg EDITOR vim
set -xg PAGER 'less -R'
# Short path
set -xg theme_short_path yes
# Supress fish message
set -U fish_greeting ""
set -xg LESS " -R "

# Tools
if status --is-interactive
  source $DIR/interactive.fish
  source $DIR/abbreviations.fish
  source $DIR/functions.fish
end

test -f $HOME/.init.fish
  and source $HOME/.init.fish ^/dev/null
