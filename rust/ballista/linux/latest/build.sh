#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Apache Arrow Ballista'
export PROJECT_REPOSITORY='https://github.com/apache/arrow-ballista.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Compile every Rust crate in the distributed scheduler and executor workspace,
# then run its workspace test suite.
export PROJECT_BUILD_COMMAND='cargo build --workspace --release && cargo test --workspace --all-targets'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
