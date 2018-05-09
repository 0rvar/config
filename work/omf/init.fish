# Short path
set -xg theme_short_path yes

# bin dir
set -xg PATH $PATH $HOME/.bin

# Use new gnu utils
set -xg PATH $PATH /usr/local/opt/findutils/libexec/gnubin

# Use python installs (pipenv etc)
set -xg PATH $PATH $HOME/Library/Python/3.6/bin

# set -xg LANG en_US.UTF-8
# set -xg LC_ALL en_US.UTF-8

set -xg LESSOPEN "| src-hilite-lesspipe.sh %s"
set -xg LESS " -R "

set -xg MINIUM_DEVELOPER_BUILD 1


# Aliases

function abbr_add --description 'append abbreviations to universal list'
	set -U fish_user_abbreviations $fish_user_abbreviations $argv
end
abbr_add 'ga=git add'
abbr_add 'ga.=git add .'
abbr_add 'gc=git commit'
abbr_add 'gca=git commit --amend'
abbr_add 'gco=git checkout'
abbr_add 'gd=git diff'
abbr_add 'gdca=git diff --cached'
abbr_add 'gf=git fetch'
abbr_add 'gl=git pull'
abbr_add 'glf=git pull --ff-only'
abbr_add 'glg=git log'
abbr_add 'glr=git pull --rebase'
abbr_add 'gp=git push'
abbr_add 'gs=git status'
abbr_add 'gsh=git show'
abbr_add 'gst=git status'

# Functions
function pco
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git checkout
end

function pcor
    set a (mktemp)
    set b (mktemp)
    git for-each-ref --sort=-committerdate refs/remotes/origin --format=%\(refname:short\) | grep -v HEAD | sed -e "s/^origin\///" > $a
    and git for-each-ref --sort=-committerdate refs/heads --format=%\(refname:short\) > b
    and grep -Fvxf $b $a | percol | xargs -i git checkout -t origin/{}
end

function pme
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git merge
end