#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Dask'
export PROJECT_REPOSITORY='https://github.com/dask/dask.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Install the checked-out project and exercise the project test suite instead
# of testing an unrelated released wheel.
export PROJECT_BUILD_COMMAND='python -m pip install --upgrade pip && python -m pip install "pyarrow>=13" && python -m pip install -e ".[test]" && python -m pytest dask/tests'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
