set DIR (dirname (realpath (status --current-filename)))
set CONFIG_ROOT (realpath $DIR/..)

source $DIR/nix-env.fish

## Rust
if test -d $HOME/.cargo/bin
  set -xg PATH $HOME/.cago/bin $PATH
end

fish_add_path $CONFIG_ROOT/bin
