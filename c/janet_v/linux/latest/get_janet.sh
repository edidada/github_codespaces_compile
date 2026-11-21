#!/usr/bin/env bash
#
# Janet（janet-lang/janet）：C 实现的动态/函数式语言，自带自举
# （bootstrap 解释器从 Janet 源码生成 amalgamation janet.c），并有一等公民宏。
# POSIX：GNU make 自举构建 + make test；Windows：MSVC build_win.bat 构建 + test。
# 端到端：编出 janet 解释器 + libjanet，再运行一段 defmacro 代码验证宏可用。
set -euo pipefail

WORK_DIR="$(pwd)/_janet_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/janet"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"
WIN=0
case "$OS" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT) WIN=1 ;;
esac
echo "==== 0. 宿主环境 ===="
uname -a

echo "==== 1. 取源码（最新 tag v1.43.0，浅克隆）===="
git -c core.autocrlf=false clone --quiet --depth=1 --branch v1.43.0 \
  https://github.com/janet-lang/janet.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
tag="$(git describe --tags --abbrev=0)"
echo "PASS: 源码就位 commit=$commit tag=$tag"

JANET_BIN=""

if [ "$WIN" -eq 1 ]; then
  echo "==== 2. Windows: MSVC build_win.bat 自举构建 ===="
  # workflow 已注入 MSVC 环境（ilammy/msvc-dev-cmd@v1）。
  # 关键：bash 的 PATH 里 Git Bash 的 /usr/bin（GNU coreutils 的 link）排在 MSVC 前面，
  # 传给 cmd.exe 后 build_win.bat 里的 `link` 会被解析成 GNU link 而非 MSVC link.exe
  # （报错 "link: extra operand"）。把 MSVC 工具链 bin 提到 PATH 最前，确保 cl/link/lib
  # 都解析到 MSVC 版本。用 cmd 原生反斜杠路径，避免 MSYS 路径转换。
  if [ -n "${VCToolsInstallDir:-}" ]; then
    # VCToolsInstallDir 是 Windows 路径（C:\...），直接拼进 bash PATH 时其中的冒号
    # 会被当成 PATH 分隔符而拆断。用 cygpath -u 转成 /c/... POSIX 形式再前置，
    # 这样 cmd.exe 继承到的 PATH 里 MSVC 的 link.exe/cl.exe 排在 GNU link 之前。
    VC_TOOLS_POSIX="$(cygpath -u "${VCToolsInstallDir}bin/Hostx64/x64" 2>/dev/null)"
    if [ -n "$VC_TOOLS_POSIX" ] && [ -d "$VC_TOOLS_POSIX" ]; then
      export PATH="$VC_TOOLS_POSIX:$PATH"
      echo "MSVC tools (POSIX): $VC_TOOLS_POSIX"
    fi
    # 再把 Git Bash 的 /usr/bin 里 GNU link/coreutils 的相对优先级压低：
    # 直接确认 cmd 解析到的 link 是 MSVC 版本。
    command -v link || true
  fi
  # cmd.exe 的 /c 在 MSYS 里会被路径转换，用 //c 规避。
  if ! cmd.exe //c "build_win.bat" >"$LOG_DIR/build.log" 2>&1; then
    tail -n 120 "$LOG_DIR/build.log" >&2
    echo "FATAL: Janet Windows 构建失败" >&2
    exit 1
  fi
  if ! cmd.exe //c "build_win.bat test" >>"$LOG_DIR/build.log" 2>&1; then
    tail -n 120 "$LOG_DIR/build.log" >&2
    echo "FATAL: Janet Windows 测试失败" >&2
    exit 1
  fi
  tail -n 15 "$LOG_DIR/build.log" || true
  [ -x "$SRC_DIR/janet.exe" ] || { echo "FATAL: 未生成 janet.exe" >&2; exit 1; }
  JANET_BIN="$SRC_DIR/janet.exe"
  cp "$JANET_BIN" "$ART_DIR/"
  [ -f "$SRC_DIR/build/libjanet.lib" ] && cp "$SRC_DIR/build/libjanet.lib" "$ART_DIR/" || true
else
  echo "==== 2. POSIX: GNU make 自举构建 + test ===="
  NPROC="$( (command -v nproc >/dev/null && nproc) || (command -v sysctl >/dev/null && sysctl -n hw.ncpu) || echo 4 )"
  if ! make -j"$NPROC" >"$LOG_DIR/build.log" 2>&1; then
    tail -n 120 "$LOG_DIR/build.log" >&2
    echo "FATAL: Janet make 构建失败" >&2
    exit 1
  fi
  if ! make test >>"$LOG_DIR/build.log" 2>&1; then
    tail -n 120 "$LOG_DIR/build.log" >&2
    echo "FATAL: Janet make test 失败" >&2
    exit 1
  fi
  tail -n 15 "$LOG_DIR/build.log" || true
  [ -x "$SRC_DIR/build/janet" ] || { echo "FATAL: 未生成 build/janet" >&2; exit 1; }
  JANET_BIN="$SRC_DIR/build/janet"
  cp "$JANET_BIN" "$ART_DIR/"
  for f in build/janet.h build/libjanet.a build/libjanet.so build/libjanet.dylib build/c/janet.c; do
    [ -f "$SRC_DIR/$f" ] && cp "$SRC_DIR/$f" "$ART_DIR/" || true
  done
fi

echo "==== 3. 端到端：运行 defmacro 宏代码验证自举与宏 ===="
# (defmacro twice (x) ~(do ,x ,x)) 展开后执行两次自增，结果 n=2。
MACRO_SRC='(defmacro twice (x) ~(do ,x ,x)) (var n 0) (twice (++ n)) (print "macro-n=" n)'
macro_out="$("$JANET_BIN" -e "$MACRO_SRC" 2>&1)" || {
  echo "FATAL: 宏代码运行失败: $macro_out" >&2
  exit 1
}
echo "宏输出: $macro_out"
if ! printf '%s\n' "$macro_out" | grep -q 'macro-n=2'; then
  echo "FATAL: 宏输出异常" >&2
  exit 1
fi
"$JANET_BIN" --version 2>&1 | head -3 || true

echo "==== 4. 收集产物 ===="
{
  echo "project=janet-lang/janet"
  echo "commit=$commit"
  echo "tag=$tag"
  echo "os=$OS"
  echo "arch=$ARCH"
  echo "macro-test=macro-n=2 PASS"
} >"$ART_DIR/build-info.txt"
echo "PASS: janet 解释器 + libjanet + 宏验证"
ls -la "$ART_DIR"
