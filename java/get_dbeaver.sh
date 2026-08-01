#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/dbeaver/dbeaver.git dbeaver
cd dbeaver
cd tools
./build.sh