#!/bin/bash

pushd .

cd "$HOME"
ln -s ~/dotfiles/ctags .ctags
ln -s ~/dotfiles/gitconfig .gitconfig
ln -s ~/dotfiles/screenrc .screenrc
ln -s ~/dotfilesdotfilesrc dotfilesrc
ln -s ~/dotfiles/zshrc .zshrc
ln -s ~/dotfiles/zshrc_complete .zshrc_complete

popd
