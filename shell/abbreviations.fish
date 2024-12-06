# Git
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

# GH CLI
abbr -a ghpc    gh pr create -w
abbr -a ghpv    gh pr view -w
abbr -a ghpo    gh pr view -w
abbr -a ghpd    gh pr diff

if type -q eza
  alias ls eza
  set __eza_l "eza -l --group-directories-first --no-user --no-time --no-permissions --icons"
  abbr -a l   "$__eza_l"
  abbr -a lst "$__eza_l --git --git-ignore"
  abbr -a lx  "eza -1 --group-directories-first"
end

abbr -a be "bundle exec"
abbr -a bn git rev-parse --abbrev-ref HEAD
abbr -a p pnpm
abbr -a pms "podman machine inspect | jq -r '.[0] | .State'"
abbr -a pm "podman machine"

abbr -a zapp "cd $HOME/develop/app"