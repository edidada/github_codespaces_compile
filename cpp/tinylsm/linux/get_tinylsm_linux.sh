#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
sudo apt install xmake python3-dev python3-venv python3-pip unzip p7zip -y
git clone https://github.com/edidada/tiny-lsm.git
cd tiny-lsm
export CMAKE_POLICY_VERSION_MINIMUM=3.5
mkdir build
xmake -y
xmake project -k cmake -y