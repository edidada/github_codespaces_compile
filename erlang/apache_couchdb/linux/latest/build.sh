#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache CouchDB'
export PROJECT_REPOSITORY='https://github.com/apache/couchdb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y help2man libicu-dev libmozjs-115-dev python3 python3-venv && ./configure --spidermonkey-version 115 --disable-docs --disable-fauxton && make -j2 && make eunit apps=couch,chttpd,couch_replicator'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
