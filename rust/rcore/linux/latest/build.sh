#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/rcore-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y build-essential
git clone --depth=1 https://github.com/rcore-os/rCore-Tutorial-v3.git "$work_root"
cd "$work_root/os"

# The upstream Makefile installs its declared RISC-V target and cargo-binutils,
# then builds the kernel and user file-system image.  `make run` is deliberately
# excluded because it opens an interactive QEMU session.
make build
test -f target/riscv64gc-unknown-none-elf/release/os.bin
test -f ../user/target/riscv64gc-unknown-none-elf/release/fs.img
