#! /bin/bash
cd "$(dirname "$0")"
svn checkout https://svn.filezilla-project.org/svn/FileZilla3/trunk FileZilla3
cd FileZilla3
autoreconf --install --force --verbose
mkdir compile
cd compile
../configure
make -j$(nproc)