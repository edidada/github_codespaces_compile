#!/usr/bin/env bash
set -euo pipefail

# LFS is a source-based distribution construction guide.  Its official Git
# tree builds and validates the book; the book itself describes the separate,
# privileged bootstrap steps required to produce a complete Linux system.
work_root="${RUNNER_TEMP:-/tmp}/linux-from-scratch-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
git clone --depth=1 --branch trunk https://git.linuxfromscratch.org/lfs.git "$work_root"
cd "$work_root"

sudo apt-get update
sudo apt-get install -y libxml2-utils xsltproc docbook-xml docbook-xsl tidy

# Build both the chunked and single-page official book.  This runs the
# project's XML validation and emits the package-download manifests.
make BASEDIR="$PWD/out" book nochunks
test -f out/index.html
test -f out/LFS-SYSD-BOOK.html
