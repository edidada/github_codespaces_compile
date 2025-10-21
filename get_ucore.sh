#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install build-essential git qemu-system-x86 vim-gnome gdb cgdb eclipse-cdt make diffutils exuberant-ctags tmux openssh-server cscope meld qgit gitg gcc-multilib gcc-multilib g++-multilib -y
sudo apt-get install zlib1g-dev libsdl1.2-dev libesd0-dev automake -y
git clone https://github.com/kiukotsu/ucore.git
cd ucore
cd labcodes/lab1
make