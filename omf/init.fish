test -f $HOME/init.extra.fish
  and source $HOME/init.extra.fish ^/dev/null

# Aliases

abbr -a ga      git add
abbr -a ga.     git add .
abbr -a gb      git branch
abbr -a gbs     git branch --sort=-committerdate
abbr -a gbsn    "git branch --sort=-committerdate | head -n 10"
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
abbr -a gshs    git show --shortstat
abbr -a gst     git status
abbr -a gwch    git whatchanged -p --abbrev-commit --pretty=medium
abbr -a gcaa    git commit --amend -a
abbr -a gcane   git commit --amend --no-edit
abbr -a gcaane  git commit --amend -a --no-edit
abbr -a gmc     git merge --continue

abbr -a ghpc    gh pr checkout
abbr -a ghpd    gh pr diff
abbr -a ghpo    gh pr view -w

abbr -a lx      exa -1 --group-directories-first


# Functions
function pco
    git for-each-ref --sort=-committerdate refs/heads/ --format=%\(refname:short\) \
        | fzf --preview="git cmp {}; echo; git theirs {}" --height=40% \
        | xargs -t git checkout
    # git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git checkout
end

function pcor
    set a (mktemp)
    set b (mktemp)
    git for-each-ref --sort=-committerdate refs/remotes/origin --format=%\(refname:short\) | grep -v HEAD | sed -e "s/^origin\///" > $a
    and git for-each-ref --sort=-committerdate refs/heads --format=%\(refname:short\) > $b
    and grep -Fvxf $b $a | fzf --preview="git cmp origin/{}" --height=40% | xargs -I \{\} -t git checkout -t origin/\{\}
end

function pme
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) \
        | fzf --preview="git cmp {}; echo; git theirs {}" --height=40% \
        | xargs -t git merge
end

function rip
  rg -C 10 -M 200 -p $argv | less -r
end
