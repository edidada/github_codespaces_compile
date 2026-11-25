#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Asterinas'
export PROJECT_REPOSITORY='https://github.com/asterinas/asterinas.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Asterinas 是 Rust 内核，需 nightly 工具链（仓库自带 rust-toolchain.toml）；
# 先安装 osdk 子命令，再按仓库 Makefile 构建内核与 OSTD，不跑需要 QEMU 的集成测试。
export PROJECT_BUILD_COMMAND='rustup show && sudo apt-get update && sudo apt-get install -y build-essential gcc-riscv64-linux-gnu && cargo install --path osdk --locked && make kernel'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"