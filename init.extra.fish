# Short path
set -xg theme_short_path yes

# bin dir
set -xg PATH $HOME/.dotfiles/.bin $PATH

set -xg LESSOPEN "| src-hilite-lesspipe.sh %s"
set -xg LESS " -R "

function say
    espeak "$argv" 2>/dev/null
end

status --is-interactive; and source (rbenv init -|psub)
