#! /bin/bash
cd "$(dirname "$0")"
sudo apt install -y flatpak
git clone -b WebKit-7617.2.4.11.8 https://github.com/WebKit/WebKit.git WebKit
cd WebKit
cmake -DPORT=GTK -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja
ninja
sudo ninja install
Tools/gtk/install-dependencies
Tools/Scripts/update-webkitgtk-libs
Tools/Scripts/build-webkit --gtk --debug