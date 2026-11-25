#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='RustSBI'
export PROJECT_REPOSITORY='https://github.com/rustsbi/rustsbi.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# xtask 的 prototyper 任务需要 riscv 目标与 objcopy（cargo-binutils/llvm-tools），
# 先补齐工具链再生成固件，最后跑 workspace 测试。
export PROJECT_BUILD_COMMAND='rustup target add riscv64gc-unknown-none-elf && rustup component add llvm-tools-preview && cargo install --locked cargo-binutils@0.4.0 && cargo run --locked --package xtask --release -- prototyper build && cargo test --workspace'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"