#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
git clone --depth 1 https://github.com/dbeaver/dbeaver.git dbeaver
cd dbeaver

# DBeaver's build script currently defaults to the removed datadam-api "main"
# branch. The repository's maintained default branch is "devel".
DATADAM_API_REF=devel ./tools/build.sh
