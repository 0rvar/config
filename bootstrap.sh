#!/usr/bin/env fish

set -e
set -u

function abort
    echo [(set_color --bold yellow) ABRT (set_color normal)] $argv
    exit 1
end

function info
    echo [(set_color --bold) ' .. ' (set_color normal)] $argv
end

function success
    echo [(set_color --bold green) ' OK ' (set_color normal)] $argv
end

set DOTFILES_ROOT (dirname (realpath (status --current-filename)))

function link_file -d "links a file keeping a backup"
  echo $argv | read -l old new
  if test -e $new
    set newf (readlink $new)
    if test "$newf" = "$old"
      success "skipped $old"
      return
    else
      mv $new $new.backup
        and success moved $new to $new.backup
        or abort "failed to backup $new to $new.backup"
    end
  end
  mkdir -p (dirname $new)
    and ln -sf $old $new
    and success "linked $old to $new"
    or abort "could not link $old to $new"
end

# Fisher tbh
if type -q fish
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  rm $__fish_config_dir/fish_plugins
  ln -s $DOTFILES_ROOT/fish/fish_plugins $__fish_config_dir/fish_plugins
  ln -s $DOTFILES_ROOT/fish/init.fish $__fish_config_dir/conf.d/init.fish
  fisher update
end


link_file $DOTFILES_ROOT/.gemrc $HOME/.gemrc
link_file $DOTFILES_ROOT/.gitconfig $HOME/.gitconfig
