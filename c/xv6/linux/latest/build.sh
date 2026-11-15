#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/xv6-riscv-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y build-essential gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
git clone --depth=1 --branch riscv https://github.com/mit-pdos/xv6-riscv.git "$work_root"
cd "$work_root"

# Build the RISC-V kernel, user programs and file-system image.  Do not start
# QEMU in CI: this branch verifies the cross-compiled OS artifacts.
# `fs.img` does not depend on the kernel target upstream, so request both.
make kernel/kernel fs.img
test -f kernel/kernel
test -f fs.img
