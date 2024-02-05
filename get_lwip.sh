#! /bin/bash
sudo apt-get install check ninja-build doxygen
git clone https://github.com/lwip-tcpip/lwip.git
cd lwip
git checkout STABLE-2_2_0_RELEASE
cp contrib/examples/example_app/lwipcfg.h.ci contrib/examples/example_app/lwipcfg.h
make -C contrib/ports/unix/check
make -C contrib/ports/unix/check check
mkdir build && cd build && cmake .. -G Ninja
cmake --build .
cmake --build . --target lwipdocs
cd ../
cd contrib/ports/unix/example_app && ./iteropts.sh
cp contrib/examples/example_app/lwipcfg.h.example contrib/examples/example_app/lwipcfg.h
make -C contrib/ports/unix/example_app TESTFLAGS="-Wno-documentation" -j 4