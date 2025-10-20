#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/cloudflare/pingora.git
cd pingora
cargo build
