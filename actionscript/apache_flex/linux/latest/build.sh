#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Flex'
export PROJECT_REPOSITORY='https://github.com/apache/flex-sdk.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='mkdir -p frameworks/libs/player/32.0 && curl -fsSL https://fpdownload.macromedia.com/get/flashplayer/updaters/32/playerglobal32_0.swc -o frameworks/libs/player/32.0/playerglobal.swc && export PLAYERGLOBAL_HOME="$PWD/frameworks/libs/player" && ant -Dbuild.noprompt=true -Dplayerglobal.version=32.0 main'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
