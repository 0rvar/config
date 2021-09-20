#!/usr/bin/env fish

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

# Fish
if type -q fish
  info "Setting up oh-my-fish"
  set OMF_INSTALL_FILE (mktemp -t oh-my-fish-install.XXXXXXXXXX)
  curl -L https://get.oh-my.fish > $OMF_INSTALL_FILE
    and success "Download oh-my-fish"
    or abort "Download oh-my-fish"
  fish $OMF_INSTALL_FILE --path=~/.local/share/omf --config=$DOTFILES_ROOT/omf --noninteractive -y
    and success "Install oh-my-fish"
    or abort "Install oh-my-fish"
  rm $OMF_INSTALL_FILE
end

link_file $DOTFILES_ROOT/.gemrc $HOME/.gemrc
link_file $DOTFILES_ROOT/.gitconfig $HOME/.gitconfig
