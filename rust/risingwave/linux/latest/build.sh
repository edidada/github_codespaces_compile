#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='RisingWave'
export PROJECT_REPOSITORY='https://github.com/risingwavelabs/risingwave.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# RisingWave's compute, storage and streaming services are a Rust workspace.
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y protobuf-compiler libopenblas-dev && cargo build --workspace --release'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
