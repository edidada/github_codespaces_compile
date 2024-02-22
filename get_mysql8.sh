# #!/bin/bash
# sudo apt install libboost1.65-all-dev -y
# sudo apt install libboost1.67-all-dev -y
git clone -b mysql-8.0.4 https://github.com/mysql/mysql-server.git
cd mysql-server
mkdir build && cd build
cmake .. -DWITH_SSL=system
make -j5
