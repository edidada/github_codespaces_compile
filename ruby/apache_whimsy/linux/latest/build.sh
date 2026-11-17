#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Whimsy'
export PROJECT_REPOSITORY='https://github.com/apache/whimsy.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='export GEM_HOME="$HOME/.gemhome" && export PATH="$HOME/.gemhome/bin:$PATH" && gem install bundler --no-document && bundle install && bundle exec rake'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
