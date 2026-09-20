#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential autoconf libssl-dev libncurses-dev libwxgtk3.2-dev
git clone --depth 1 --recursive --branch OTP-29.1 https://github.com/erlang/otp.git otp
cd otp
./otp_build autoconf
./configure --without-javac
make -j2
