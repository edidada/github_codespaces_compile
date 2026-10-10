#!/usr/bin/env bash
set -euo pipefail
work_root="${RUNNER_TEMP:-/tmp}/keras-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
git clone --depth=1 https://github.com/keras-team/keras.git "$work_root"
cd "$work_root"
python -m pip install --upgrade pip build
python -m build
test -n "$(find dist -maxdepth 1 -name '*.whl' -print -quit)"
