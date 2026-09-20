#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Buildr'
export PROJECT_REPOSITORY='https://github.com/apache/buildr.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='bundle install && mkdir -p "$HOME/.buildr" && printf "repositories:\\n  mirrors:\\n    - https://repo.maven.apache.org/maven2/\\n" > "$HOME/.buildr/settings.yaml" && printf "require '\''uri'\''\\nURI.send(:remove_const, :File) if URI.const_defined?(:File, false)\\n" > /tmp/buildr-uri-compat.rb && RUBYOPT=-r/tmp/buildr-uri-compat.rb bundle exec rspec'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
