#!/bin/bash

# Install vundle
git clone https://github.com/gmarik/vundle.git $PWD/.vim/bundle/vundle

# Install vundle bundles
vim +BundleInstall +qall
