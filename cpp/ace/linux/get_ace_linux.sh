#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
