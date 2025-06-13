#! /bin/bash
cd "$(dirname "$0")"
mkdir TBuild
cd TBuild
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git automake cmake wget pkg-config gnu-tar ninja nasm meson
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
git clone --recursive https://github.com/telegramdesktop/tdesktop.git
./tdesktop/Telegram/build/prepare/mac.sh