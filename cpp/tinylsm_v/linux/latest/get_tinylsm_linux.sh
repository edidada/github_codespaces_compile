#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
sudo apt install curl python3-dev python3-venv python3-pip unzip p7zip -y
curl -fsSL https://xmake.io/shget.text | bash
export PATH="$HOME/.local/bin:$HOME/.xmake/bin:$PATH"
git clone https://github.com/edidada/tiny-lsm.git
cd tiny-lsm
# The upstream file references a local package repository named "build", but
# that directory is not part of the checkout. All declared packages are
# available from xmake's public repository.
sed -i '/add_repositories("local-repo build")/d' xmake.lua
export CMAKE_POLICY_VERSION_MINIMUM=3.5
xmake -y
xmake project -k cmake -y
