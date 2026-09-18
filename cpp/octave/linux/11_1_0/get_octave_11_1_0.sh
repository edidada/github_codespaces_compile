#!/bin/bash
wget https://ftpmirror.gnu.org/octave/octave-11.1.0.tar.gz
tar -xzf octave-11.1.0.tar.gz
cd octave-11.1.0
sudo apt install -y \
  build-essential gfortran g++ make \
  libopenblas-dev liblapack-dev libpcre3-dev \
  libreadline-dev libfltk1.3-dev libqt5svg5-dev \
  libqscintilla2-qt5-dev llvm-dev texinfo \
  bison flex libtool autoconf automake \
  gnuplot libhdf5-dev libfftw3-dev
mkdir build && cd build
../configure
make -j$(nproc)
make check
sudo make install