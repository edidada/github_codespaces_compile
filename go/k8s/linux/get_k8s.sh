#! /bin/bash
cd "$(dirname "$0")"
git clone -b release-1.29 https://github.com/kubernetes/kubernetes.git
cd kubernetes
make