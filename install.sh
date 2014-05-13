#!/bin/bash
# Fresh computer setup

echo "### Enable partners and add Spotify repo:"
echo "deb http://repository.spotify.com stable non-free"
software-properties-gtk

echo "### Adding spotify key..."
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59

echo "### Adding sublime-text ppa..."
sudo add-apt-repository -y ppa:webupd8team/sublime-text-2

echo "### Refreshing package lists"
sudo apt-get update -qq

echo "### Installing chrome and codecs..."
sudo apt-get install -yqq ubuntu-restricted-extras chromium-browser chromium-codecs-ffmpeg-extra

echo "### Installing sublime-text 2, spotify, quassel and skype"
sudo apt-get install -yqq sublime-text spotify-client skype quassel

echo "### Installing haskell-platform+"
sudo apt-get install -yqq haskell-platform haskell-platform-prof hlint cabal-install \
  libghc-lens-dev libghc-lens-prof

echo "### Installing xmonad and friends..."
sudo apt-get install -yqq xmonad libghc-xmonad-dev libghc-xmonad-contrib-dev \
  gnome-panel libappindicator1 kupfer indicator-multiload python-gpgme

echo "Installing zsh"
sudo apt-get install -yqq zsh 

echo "### Distributing dotfiles"
dir=$PWD
pushd ~

echo "ln -s $dir/.zshrc"
ln -s $dir/.zshrc
echo "cp $dir/.zshrc.after $PWD/"
cp $dir/.zshrc.after $PWD/
echo "ln -s $dir/.bin"
ln -s $dir/.bin

echo "mkdir -f .cabal; ln -s $dir/cabal_config $PWD/.cabal/config"
mkdir -f .cabal; ln -s $dir/cabal_config $PWD/.cabal/config
echo "ln -s $dir/.ghci"
ln -s $dir/.ghci
echo "mkdir -f $PWD/.xmonad; rm -f $PWD/.xmonad/xmonad.hs; ln -s $dir/xmonad.hs $PWD/.xmonad/xmonad.hs"
mkdir -f $PWD/.xmonad; rm -f $PWD/.xmonad/xmonad.hs; ln -s $dir/xmonad.hs $PWD/.xmonad/xmonad.hs

echo "ln -s $dir/.gemrc"
ln -s $dir/.gemrc
echo "ln -s $dir/.irbrc"
ln -s $dir/.irbrc

echo "ln -s $dir/.vimrc"
ln -s $dir/.vimrc
echo "ln -s $dir/.vim"
ln -s $dir/.vim
echo "ln -s $dir/.gvimrc"
ln -s $dir/.gvimrc

echo "ln -s $dir/.Xmodmap"
ln -s $dir/.Xmodmap
echo "ln -s $dir/.gitconfig"
ln -s $dir/.gitconfig
echo "mkdir .xmonad; ln -s $dir/xmonad.hs $PWD/.xmonad/xmonad.hs"
mkdir .xmonad; ln -s $dir/xmonad.hs $PWD/.xmonad/xmonad.hs



popd

echo "### Installing oh-my-zsh and setting shell to zsh..."
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
chsh -s /bin/zsh

echo "### Compiling xmonad..."
xmonad --recompile

echo "### TODO:"
echo "$ indicator-multiload"
echo "install dropbox"
echo "Start sublime once, symlink sublime config, install sublime package manager, install packages (theme, sublime_packages.txt)
