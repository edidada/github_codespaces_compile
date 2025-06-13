#! /bin/bash
cd "$(dirname "$0")"
# 安装 pipx（如果还没有）
sudo apt update
sudo apt install python3-pip -y
python3 -m pip install --user pipx
python3 -m pipx ensurepath
# 使用 pipx 安装 poetry
pipx install poetry
poetry --version
mkdir TBuild
cd TBuild
git clone --recursive https://github.com/telegramdesktop/tdesktop.git
git checkout v5.15.3
./tdesktop/Telegram/build/prepare/linux.sh