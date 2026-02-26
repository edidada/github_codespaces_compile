#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/servo/servo
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
sudo apt install python3-pip python3-venv
cd servo
./mach bootstrap