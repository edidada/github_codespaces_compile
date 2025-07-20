#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
git clone https://github.com/DOCGroup/ACE_TAO.git
cd ACE_TAO/ACE
git checkout 675c2f88cf84591e0dcf995f6d0dddd2fd807df0
git clone https://github.com/DOCGroup/MPC.git
cd MPC
git checkout b085809b65705fe56d66bd094b0f73f1002f02d7
cd ../
export ACE_ROOT=$(pwd)
echo "=> ACE_ROOT: $ACE_ROOT"
cd "$ACE_ROOT/ace"
perl "$ACE_ROOT/bin/mwc.pl" -type cmake "$ACE_ROOT/ace/ace.mwc" -workers 6
cd "$ACE_ROOT/apps/gperf/src"
perl "$ACE_ROOT/bin/mwc.pl" -type cmake .
mkdir -p "$ACE_ROOT/ace"
cat > "$ACE_ROOT/ace/config.h" << 'EOF'
#ifdef linux
# include "ace/config-linux.h"
#else
# include "ace/config-win32.h"
#endif
EOF
echo "config.h"
cat config.h
mkdir -p build
cmake -S . -B build
cmake --build build -j6
cd "$ACE_ROOT/apps/gperf/src"
mkdir -p build
cmake -S . -B build
cmake --build build -j6
