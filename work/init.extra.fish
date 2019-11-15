# Editor
set -xg EDITOR vim

# Short path
set -xg theme_short_path yes

# Dir colors, ls
if type -q vivid
    set -xg LS_COLORS (vivid -m 8-bit generate molokai)
end
alias ls exa
alias l "exa -l --group-directories-first --no-user --no-time --no-permissions --icons"
alias lst "l --git --git-ignore"

# bin dir
set -xg PATH $HOME/.dotfiles/work/.bin $PATH
set -xg PATH $HOME/.dotfiles/.bin $PATH
set -xg PATH $HOME/.bin $PATH

# Rust
set -xg PATH $HOME/.cargo/bin $PATH

# Use new gnu utils
# set -xg PATH /usr/local/opt/findutils/libexec/gnubin $PATH

# Use python installs (pipenv etc)
# set -xg PATH $HOME/Library/Python/3.6/bin $PATH
# set -xg PATH $HOME/Library/Python/2.7/bin $PATH

# GO bin dir
# set -xg PATH $HOME/go/bin $PATH

# ESP32
# function get_esp32
#     set -xg PATH $HOME/esp/xtensa-esp32-elf/bin $PATH

#     set -xg IDF_PATH $HOME/esp/esp-idf
#     set -xg PATH $IDF_PATH/components/esptool_py/esptool $PATH
#     set -xg PATH $IDF_PATH/components/espcoredump $PATH
#     set -xg PATH $IDF_PATH/components/partition_table $PATH
# end

# ESP docker
function esp_create
    docker run -ti -v $PWD:/home/project rust-esp:latest create-project
end
function esp_menuconfig
    docker run -ti -v $PWD:/home/project rust-esp:latest make menuconfig
end
function esp_build
    docker run -ti -v $PWD:/home/project rust-esp:latest
end
function esp_xbuild
    docker run -ti -v $PWD:/home/project rust-esp:latest xbuild-project
end
function esp_image
    docker run -ti -v $PWD:/home/project rust-esp:latest image-project
end
function esp_bindgen
    docker run -ti -v $PWD:/home/project rust-esp:latest bindgen-project
end
function esp_shell
    docker run -ti -v $PWD:/home/project rust-esp:latest bash
end
abbr -a esp_flash esptool write_flash 0x10000 esp-app.bin

# Java
set -xg PATH $HOME/.jenv/bin $PATH
source (jenv init -)

# Android
# set -xg ANDROID_HOME $HOME/Library/Android/sdk/
# set -xg PATH $ANDROID_HOME/platform-tools/ $PATH
set -xg ANDROID_HOME $HOME/Library/Android/sdk
set -xg PATH $PATH $ANDROID_HOME/emulator
set -xg PATH $PATH $ANDROID_HOME/tools
set -xg PATH $PATH $ANDROID_HOME/tools/bin
set -xg PATH $PATH $ANDROID_HOME/platform-tools

set -xg LANG sv_SE.UTF-8
set -xg LC_ALL sv_SE.UTF-8

set -xg LESSOPEN "| src-hilite-lesspipe.sh %s"
set -xg LESS " -R "

status --is-interactive; and source (rbenv init -|psub)

function kb
    echo Ctrl-f\t\tFind a file.
    echo Ctrl-r\t\tSearch through command history.
    echo Alt-o\t\tcd into sub-directories \(recursively searched\).
    echo Alt-Shift-o\tcd into sub-directories, including hidden ones.
    echo Ctrl-o\t\tOpen a file/dir using default editor \($EDITOR\)
    echo Ctrl-g\t\tOpen a file/dir using xdg-open or open command
end

# fuck
thefuck --alias | source

# Notify
abbr -a no "and say rafiki; or say bazooka"

abbr -a bn git rev-parse --abbrev-ref HEAD