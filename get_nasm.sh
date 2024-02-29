#! /bin/bash
cd "$(dirname "$0")"
git clone -b nasm-2.16.01 https://github.com/netwide-assembler/nasm.git
cd nasm
./autogen.sh
./configure
make all
python3 ./travis/nasm-t.py run