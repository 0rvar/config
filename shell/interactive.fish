## Dir colors, ls
if type -q vivid
    set -xg LS_COLORS (vivid generate molokai)
end

if command -v starship > /dev/null
  starship init fish | source
end

if command -v direnv > /dev/null
  direnv hook fish | source
end

if command -v zoxide > /dev/null
  zoxide init fish | source
end

if command -v atuin > /dev/null
  atuin init fish | source
else 
  echo "atuin not found"
end