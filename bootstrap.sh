#!/bin/bash

pushd .

cd "$HOME"

rm .zshrc .bash_profile .gitconfig

ln -s ~/dotfiles/ctags .ctags
ln -s ~/dotfiles/gitconfig .gitconfig
ln -s ~/dotfiles/screenrc .screenrc
ln -s ~/dotfiles/vimrc .vimrc
ln -s ~/dotfiles/zshrc .zshrc
ln -s ~/dotfiles/bash_profile .bash_profile

## NB: This is needed for ripgrep
sudo apt-get install libpcre2-8-0

popd
