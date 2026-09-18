#! /bin/bash
git clone https://github.com/chriskohlhoff/asio.git
cd asio
git checkout asio-1-29-0
cd asio
./autogen.sh
./configure
make && make check
