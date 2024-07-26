#! /bin/bash
cd "$(dirname "$0")"
rm -rf nasm
git clone -b nasm-2.12 https://github.com/netwide-assembler/nasm.git
cd nasm
export PERL5LIB=$PWD:$PERL5LIB
./autogen.sh
./configure
make all