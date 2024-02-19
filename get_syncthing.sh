#! /bin/bash
sudo apt update
git clone -b v1.27.3 https://github.com/syncthing/syncthing.git
cd syncthing
go run build.go