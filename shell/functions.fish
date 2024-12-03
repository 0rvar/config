
# Checkout a branch with fzf
function pco
    git for-each-ref --sort=-committerdate refs/heads/ --format=%\(refname:short\) \
        | fzf --preview="git cmp {}; echo; git theirs {}" --height=40% \
        | xargs -t git checkout
    # git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) | percol | xargs git checkout
end

# Checkout a remote branch with fzf
function pcor
    set a (mktemp)
    set b (mktemp)
    git for-each-ref --sort=-committerdate refs/remotes/origin --format=%\(refname:short\) | grep -v HEAD | sed -e "s/^origin\///" > $a
    and git for-each-ref --sort=-committerdate refs/heads --format=%\(refname:short\) > $b
    and grep -Fvxf $b $a | fzf --preview="git cmp origin/{}" --height=40% | xargs -I \{\} -t git checkout -t origin/\{\}
end

# Merge a branch with fzf 
function pme
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=%\(refname:short\) \
        | fzf --preview="git cmp {}; echo; git theirs {}" --height=40% \
        | xargs -t git merge
end

# Wrap rg with context and pager
function rip
  rg -C 10 -M 200 -p $argv | less -r
end

# Rudimentary sourcing of .env files
function envsource
  for line in (cat $argv | grep -v '^#')
    set item (string split -m 1 '=' $line)
    set -x $item[1] $item[2]
    echo "Exported key $item[1]"
  end
end

# ffmpeg wrapper for converting a video to 720p
function ff720 --description 'Resize video maintaining aspect ratio with 720p target'
    if test (count $argv) -lt 2
        echo "Usage: ff720 input_file output_file [ffmpeg_args...]"
        return 1
    end

    set -l input $argv[1]
    set -l output $argv[2]
    set -l extra_args $argv[3..-1]

    # Get video dimensions
    set -l dimensions (ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 $input)
    set -l width (echo $dimensions | cut -d'x' -f1)
    set -l height (echo $dimensions | cut -d'x' -f2)

    # Calculate scaling
    if test $width -gt $height
        set scale "scale=720:'-2'"
    else
        set scale "scale='-2':720"
    end

    # Run ffmpeg with extra args
    ffmpeg -i $input -vf $scale -preset veryslow $extra_args $output
    dust $output
end
