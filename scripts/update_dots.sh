#!/bin/bash
# update dotfiles from repo

git -C ~/src pull
bash ~/src/install_dotfiles.sh
source ~/.bashrc
