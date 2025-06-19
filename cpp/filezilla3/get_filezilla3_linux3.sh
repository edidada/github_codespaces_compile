#! /bin/bash
cd "$(dirname "$0")"
svn co https://svn.filezilla-project.org/svn/FileZilla3/trunk FileZilla3
cd FileZilla3
svn switch https://svn.filezilla-project.org/svn/FileZilla3/tags/3.56.0
autoreconf --install --force --verbose
mkdir compile
cd compile
../configure
make -j$(nproc)