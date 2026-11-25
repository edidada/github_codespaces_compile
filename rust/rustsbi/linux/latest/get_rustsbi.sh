#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='RustSBI'
export PROJECT_REPOSITORY='https://github.com/rustsbi/rustsbi.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# firmware/prototyper 的 build.rs 需要 target/prototyper/generated_*.rs，
# 由仓库自带 xtask 的 `cargo prototyper build` 生成，必须先执行再测试。
export PROJECT_BUILD_COMMAND='cargo run --locked --package xtask --release -- prototyper build && cargo test --workspace'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"