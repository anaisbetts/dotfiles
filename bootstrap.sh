#!/bin/bash

pushd .

cd "$HOME"

rm .zshrc .zshrc_complete .bash_profile

ln -s ~/dotfiles/ctags .ctags
ln -s ~/dotfiles/gitconfig .gitconfig
ln -s ~/dotfiles/screenrc .screenrc
ln -s ~/dotfiles/vimrc .vimrc
ln -s ~/dotfiles/zshrc .zshrc
ln -s ~/dotfiles/bash_profile .bash_profile

popd
