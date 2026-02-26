#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
which pip
which python
pip install setuptools wheel
git clone https://github.com/patroni/patroni.git
cd patroni
git checkout v4.0.0
ls -la setup.py
pip install -r requirements.txt
pip install -r requirements.dev.txt
python setup.py bdist_wheel
ls -la dist/