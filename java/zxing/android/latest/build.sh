#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='ZXing Android'
export PROJECT_REPOSITORY='https://github.com/zxing/zxing.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# The legacy APK POM inherits zxing-parent 3.5.3, which makes Maven request an
# android-core artifact that was never published to Central.  Build it against
# the parent from this checkout so the Android modules are resolved from the
# same reactor as the rest of ZXing.
export PROJECT_BUILD_COMMAND='zxing_version="$(mvn -q -DforceStdout help:evaluate -Dexpression=project.version)" && sed -i "/<artifactId>zxing-parent<\\/artifactId>/,/<\\/parent>/s#<version>3.5.3</version>#<version>${zxing_version}</version>#" android/pom.xml && mvn -B -ntp -Pbuild-android -DadditionalJOption=-Xdoclint:none package'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
