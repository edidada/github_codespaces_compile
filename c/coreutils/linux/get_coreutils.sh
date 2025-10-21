#! /bin/bash
sudo apt-get update
sudo apt-get install help2man texinfo gnulib -y
sudo apt-get install gettext gperftools-dev -y
sudo apt-get install autopoint gperf makeinfo texi2pdf -y
git clone git://git.sv.gnu.org/coreutils
cd coreutils
git checkout v9.4
./bootstrap