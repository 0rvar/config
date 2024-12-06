set DIR (dirname (realpath (status --current-filename)))
set CONFIG_ROOT (realpath $DIR/..)

source $DIR/nix-env.fish

## Rust
if test -d $HOME/.cargo/bin
  fish_add_path $HOME/.cargo/bin
end

fish_add_path $CONFIG_ROOT/bin
