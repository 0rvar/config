# Short path
set -xg theme_short_path yes

# bin dir
set -xg PATH $HOME/.dotfiles/.bin $PATH

set -xg LESSOPEN "| src-hilite-lesspipe.sh %s"
set -xg LESS " -R "
