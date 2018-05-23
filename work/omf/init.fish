# Short path
set -xg theme_short_path yes

# bin dir
set -xg PATH $HOME/.bin $PATH

# Use new gnu utils
set -xg PATH /usr/local/opt/findutils/libexec/gnubin $PATH

# Use python installs (pipenv etc)
set -xg PATH $HOME/Library/Python/3.6/bin $PATH 

set -xg LANG en_US.UTF-8
set -xg LC_ALL en_US.UTF-8

set -xg LESSOPEN "| src-hilite-lesspipe.sh %s"
set -xg LESS " -R "

set -xg MINIUM_DEVELOPER_BUILD 1


# Aliases

abbr -a ga      git add
abbr -a ga.     git add .
abbr -a gb      git branch
abbr -a gc      git commit
abbr -a gca     git commit --amend
abbr -a gcp     git cherry-pick
abbr -a gco     git checkout
abbr -a gd      git diff
abbr -a gdca    git diff --cached
abbr -a gf      git fetch
abbr -a gfa     git fetch --all --prune
abbr -a gl      git pull
abbr -a glf     git pull --ff-only
abbr -a glg     git log
abbr -a glr     git pull --rebase
abbr -a glg     git log --stat --max-count=10
abbr -a glgg    git log --graph --max-count=10
abbr -a glgga   git log --graph --decorate --all
abbr -a glo     git log --oneline --decorate --color
abbr -a glog    git log --oneline --decorate --color --graph
abbr -a gp      git push
abbr -a grba    git rebase --abort
abbr -a grbc    git rebase --continue
abbr -a grbi    git rebase --interactive
abbr -a gs      git status
abbr -a gsh     git show
abbr -a gst     git status
abbr -a gwch    git whatchanged -p --abbrev-commit --pretty=medium


# Functions
function pco
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git checkout
end

function pcor
    set a (mktemp)
    set b (mktemp)
    git for-each-ref --sort=-committerdate refs/remotes/origin --format=%\(refname:short\) | grep -v HEAD | sed -e "s/^origin\///" > $a
    and git for-each-ref --sort=-committerdate refs/heads --format=%\(refname:short\) > $b
    and grep -Fvxf $b $a | percol | xargs -i git checkout -t origin/\{\}
end

function pme
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git merge
end

function rip
  rg -C 10 -M 200 -p $argv | less -r
end