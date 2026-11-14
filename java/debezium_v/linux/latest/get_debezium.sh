#!/usr/bin/env bash
#
# Debezium（debezium/debezium，Kafka Connect CDC 平台）源码编译。
# 上游 README 要求 JDK 21+、Maven 3.9.8+（用仓库自带 ./mvnw）；
#   ./mvnw clean verify -Dquick  = 只产 artifacts，跳过测试 / IT / checkstyle /
#   formatter / revapi / docker，不需要 Docker daemon。
# 本脚本在 GitHub 托管 runner 的多 OS / 多 CPU 矩阵上执行
# （ubuntu x86_64、ubuntu-24.04-arm、windows-latest 走 Git Bash、macos-latest arm64）。
set -euo pipefail

WORK_DIR="$(pwd)/_debezium_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/debezium"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

echo "==== 0. 宿主环境 ===="
uname -a
echo "uname -m: $(uname -m)"
java -version 2>&1 | sed -n '1,3p'

echo "==== 1. 取源码（main 浅克隆，保留 LF）===="
# Windows runner 的 core.autocrlf 会把 mvnw / *.sh 转成 CRLF，显式关掉。
git -c core.autocrlf=false clone --quiet --depth=1 https://github.com/debezium/debezium.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"
printf 'commit=%s\n' "$commit" >"$LOG_DIR/revision.txt"

echo "==== 2. Maven / JDK 版本 ===="
# 用 bash 显式执行，规避 Windows 下 mvnw 可执行位 / shebang 的问题。
if ! bash ./mvnw -version >"$LOG_DIR/maven-version.txt" 2>&1; then
    tail -n 40 "$LOG_DIR/maven-version.txt"
    echo "FATAL: mvnw 不可用" >&2
    exit 1
fi
sed -n '1,8p' "$LOG_DIR/maven-version.txt"

echo "==== 3. 编译：clean verify -Dquick ===="
build_log="$LOG_DIR/mvn-build.log"
if ! bash ./mvnw -B -ntp \
        -Dquick -DskipTests=true -DskipITs=true -Ddocker.skip=true \
        clean verify >"$build_log" 2>&1; then
    tail -n 120 "$build_log"
    echo "FATAL: Debezium 编译失败" >&2
    exit 1
fi
grep -E "BUILD SUCCESS|Total time" "$build_log" | tail -n 5 || true

echo "==== 4. 收集产物 ===="
{
    echo "project=debezium/debezium"
    echo "commit=$commit"
    echo "os=$(uname -s)"
    echo "arch=$(uname -m)"
    echo "java=$(java -version 2>&1 | sed -n '1p')"
} >"$ART_DIR/build-info.txt"
# 只挑核心模块与几个连接器的主 jar，控制上传体积（排除 sources/javadoc/tests）。
for module in debezium-util debezium-api debezium-config debezium-core \
              debezium-embedded debezium-connector-mysql \
              debezium-connector-postgres debezium-connector-mongodb; do
    for jar in "$module"/target/*.jar; do
        [ -f "$jar" ] || continue
        case "$jar" in *sources*|*javadoc*|*tests*) continue ;; esac
        cp "$jar" "$ART_DIR/"
    done
done
count="$(find "$ART_DIR" -name '*.jar' | wc -l)"
[ "$count" -gt 0 ] || { echo "FATAL: 没有产出任何 jar" >&2; exit 1; }
echo "PASS: 产出 $count 个 jar"
ls -1 "$ART_DIR"
