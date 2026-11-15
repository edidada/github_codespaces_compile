#! /usr/bin/env bash
#
# QuestDB（questdb/questdb，Java + 少量 C/C++/Rust 目标）源码编译：
# 官方构建入口就是 Maven（仓库根有 pom.xml，无 mvnw，用 runner 自带 mvn）
# 主要产物 core/target/questdb-*.jar（内嵌服务端可 java -jar 启动）。
#
# 上游：https://github.com/questdb/questdb
# 官方构建说明：README「Building QuestDB」/ developer docs。
set -euo pipefail

WORK_DIR="$(pwd)/_questdb_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/questdb"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

echo "==== 0. 宿主环境 ===="
uname -a
sed -n 's/^PRETTY_NAME=//p' /etc/os-release | sed -n '1p' | tr -d '"'
java -version 2>&1 | sed -n '1p'

echo "==== 1. 取源码 ===="
git clone --quiet --depth=1 https://github.com/questdb/questdb.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"
printf 'commit=%s\n' "$commit" >"$LOG_DIR/revision.txt"

[ -f pom.xml ] || { echo "FATAL: 仓库根没有 pom.xml" >&2; exit 1; }
command -v mvn >/dev/null 2>&1 || { echo "FATAL: runner 上没有 maven，无法构建" >&2; exit 1; }
mvn --version 2>&1 | sed -n '1p'

echo "==== 2. 编译：mvn package ----"
build_log="$LOG_DIR/mvn-package.log"
if ! mvn --batch-mode --no-transfer-progress -DskipTests package >"$build_log" 2>&1; then
    tail -n 80 "$build_log"
    echo "FATAL: QuestDB 编译失败（mvnw package）" >&2
    exit 1
fi
grep -E '^BUILD SUCCESS' "$build_log" | tail -n 1 || true

echo "==== 3. 产物验活 ===="
jar_list="$(find core -maxdepth 3 -type f -name 'questdb-*.jar' | sort)"
[ -n "$jar_list" ] || {
    echo "---- core/target 目录 ----"
    ls -l core/target 2>/dev/null | head -n 20 || true
    echo "FATAL: 没产出 questdb-*.jar" >&2
    exit 1
}
printf '%s\n' "$jar_list" | tee "$WORK_DIR/jars.txt"
main_jar="$(printf '%s\n' "$jar_list" | grep -Ev 'sources|javadoc|tests?' | sed -n '1p')"
[ -n "$main_jar" ] || main_jar="$(printf '%s\n' "$jar_list" | sed -n '1p')"
entry_ok="$(jar tf "$main_jar" | grep -c 'io/questdb' || true)"
[ "$entry_ok" -ge 1 ] || { echo "FATAL: $main_jar 里没有 io/questdb 条目" >&2; exit 1; }
echo "PASS: $main_jar 含 $entry_ok 个 io/questdb 条目"

echo "==== 4. 归档 ===="
cp "$WORK_DIR/jars.txt" "$ART_DIR/jar-list.txt"
cp "$LOG_DIR/revision.txt" "$ART_DIR/revision.txt"
cp "$build_log" "$ART_DIR/mvn-package.log" 2>/dev/null || true
while IFS= read -r jar; do
    cp "$jar" "$ART_DIR/"
done <"$WORK_DIR/jars.txt"
( cd "$ART_DIR" && sha256sum -- "./$(basename "$main_jar")" >sha256sums.txt )
ls -l "$ART_DIR"
echo "PASS: QuestDB 源码编译完成，全部产物在 $ART_DIR"
