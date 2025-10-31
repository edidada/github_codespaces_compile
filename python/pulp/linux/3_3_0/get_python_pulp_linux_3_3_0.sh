#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/coin-or/pulp.git
cd pulp
git checkout 3.3.0
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
pip install --group=dev --editable .