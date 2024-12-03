#!/usr/bin/env bash
set -euo pipefail

# Colors for output formatting
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)

abort() {
  echo -e "[$BOLD$YELLOW ABRT $NORMAL] $*" >&2
  exit 1
}

info() {
  echo -e "[$BOLD .. $NORMAL] $*"
}

success() {
  echo -e "[$BOLD$GREEN OK $NORMAL] $*"
}
skip() {
  echo -e "[$BOLD$GREEN -- $NORMAL] $*"
}

# Get the directory where the script is located
CONFIG_ROOT="$(dirname "$(realpath "${BASH_SOURCE[0]}/..")")"

link_file() {
  local old="$1"
  local new="$2"

  if [[ -e "$new" ]]; then
    local newf
    newf=$(readlink "$new")
    if [[ "$newf" == "$old" ]]; then
      skip "skipped $old"
      return 0
    else
      if mv "$new" "$new.backup"; then
        success "moved $new to $new.backup"
      else
        abort "failed to backup $new to $new.backup"
      fi
    fi
  fi

  mkdir -p "$(dirname "$new")"
  if ln -sf "$old" "$new"; then
    success "linked $old to $new"
  else
    abort "could not link $old to $new"
  fi
}

# Link configuration files
link_file "$CONFIG_ROOT/shell/config.fish" "${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/config.fish"
link_file "$CONFIG_ROOT/shell/starship.toml" "$HOME/.config/starship.toml"
link_file "$CONFIG_ROOT/.gitconfig" "$HOME/.gitconfig"
link_file "$CONFIG_ROOT/.gemrc" "$HOME/.gemrc"
