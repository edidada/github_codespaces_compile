#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Libra'
export PROJECT_REPOSITORY='https://github.com/libra-tools/libra.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# libra 依赖 fontconfig（yeslogic-fontconfig-sys），托管 runner 需先安装开发包。
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y libfontconfig1-dev pkg-config && cargo test --workspace --all-targets'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"