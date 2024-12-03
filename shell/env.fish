set DIR (dirname (realpath (status --current-filename)))
set CONFIG_ROOT (realpath $DIR/..)

source $DIR/nix-env.fish

## Rust
if test -d $HOME/.cargo/bin
  set -xg PATH $HOME/.cago/bin $PATH
end

## Bin
fish_add_path $CONFIG_ROOT/work/.bin
fish_add_path $CONFIG_ROOT/.bin
if test -d $HOME/.bin
  fish_add_path $HOME/.bin
end
if test -d $HOME/.local/bin
  fish_add_path $HOME/.local/bin
end

