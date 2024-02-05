#! /bin/bash
git clone https://github.com/chriskohlhoff/asio.git
cd asio
git checkout asio-1-29-0
./autogen.sh
./configure
make && make check
