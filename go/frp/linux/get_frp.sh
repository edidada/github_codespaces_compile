#! /bin/bash
cd "$(dirname "$0")"
git clone -b v0.57.0 https://github.com/fatedier/frp.git
cd frp
go build