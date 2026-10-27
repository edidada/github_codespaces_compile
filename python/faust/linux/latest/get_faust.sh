#! /usr/bin/env bash
#
# Faust Python 流处理库（faust-streaming/faust）源码编译：
# 官方构建入口是 setuptools：use_scm_version=True（版本来自 git tag，必须完整
# 克隆且带全部 tag）；setup.py 默认 USE_CYTHON=True，会从
# faust/_cython/streams.pyx 编译 C 扩展（Linux 上产出
# faust/_cython/streams.cpython-3XX-x86_64-linux-gnu.so）。
#
# 上游：https://github.com/faust-streaming/faust（robinhood/faust 的维护分支）
# 官方构建说明：README / docs（安装首选 pip，源码构建即 python -m build / setup.py）
#
# 构建策略：--no-isolation + 手动备齐构建依赖（build/setuptools/wheel/cython/
# setuptools_scm），确保 Cython 扩展真的被 Cython 化，而不是空 import 走纯 Python
# 兜底分支。requires-python >= 3.10，ubuntu-22.04 runner 自带 python3.10 ✓。
set -euo pipefail

WORK_DIR="$(pwd)/_faust_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/faust"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

echo "==== 0. 宿主环境 ===="
uname -a
python3 --version
python3 -m pip --version
nproc

echo "==== 1. 取源码 ===="
# 完整克隆（非 shallow）：use_scm_version 从 git tag 推导版本号
git clone --quiet https://github.com/faust-streaming/faust.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
tags="$(git tag | wc -l)"
echo "PASS: 源码就位 commit=$commit tags=$tags"
printf 'commit=%s\ntags=%s\n' "$commit" "$tags" >"$LOG_DIR/revision.txt"

echo "==== 2. 构建依赖就位（no-isolation 模式手动备齐） ===="
python3 -m pip install --quiet --upgrade pip
python3 -m pip install --quiet build setuptools wheel cython setuptools_scm | sed -n '1,3p'
python3 -c 'import Cython; print("Cython", Cython.__version__)'
python3 -c 'from importlib.metadata import version; print("setuptools_scm", version("setuptools-scm"))'

echo "==== 3. 编译打包：python -m build --wheel ----"
build_log="$LOG_DIR/build-wheel.log"
if ! python3 -m build --no-isolation --wheel --outdir "$ART_DIR" >"$build_log" 2>&1; then
    tail -n 80 "$build_log"
    echo "FATAL: Faust 编译打包失败（python -m build --wheel）" >&2
    exit 1
fi
grep -E 'Compiling|copying.*(pyx|\.so|\.c\b)' "$build_log" | tail -n 5 || true

echo "==== 4. 产物验活 ===="
wheel="$(cd "$ART_DIR" && ls faust_streaming-*.whl | sed -n '1p')"
[ -n "$wheel" ] || {
    ls -l "$ART_DIR"
    echo "FATAL: 没产出 faust_streaming-*.whl" >&2
    exit 1
}
so_entry="$(python3 -m zipfile -l "$ART_DIR/$wheel" | grep -E 'faust/_cython/streams.*\.so' || true)"
[ -n "$so_entry" ] || {
    python3 -m zipfile -l "$ART_DIR/$wheel" | grep '_cython' || true
    echo "FATAL: wheel 里没有编译出的 _cython/streams C 扩展（.so）" >&2
    exit 1
}
echo "PASS: wheel 内含 C 扩展：$so_entry"

echo "==== 5. 冒烟：venv 里装包并 import ----"
python3 -m venv "$WORK_DIR/venv"
smoke_log="$LOG_DIR/smoke.log"
if ! "$WORK_DIR/venv/bin/pip" install --quiet "$ART_DIR/$wheel" >"$smoke_log" 2>&1; then
    tail -n 30 "$smoke_log"
    echo "FATAL: wheel 无法安装（依赖解析失败）" >&2
    exit 1
fi
ver="$("$WORK_DIR/venv/bin/python" -c 'import faust; print(faust.__version__)')"
echo "PASS: import faust => $ver"
[ -n "$ver" ] || { echo "FATAL: faust.__version__ 为空" >&2; exit 1; }

echo "==== 6. 归档 ===="
cp "$LOG_DIR/revision.txt" "$ART_DIR/revision.txt"
cp "$build_log" "$ART_DIR/build-wheel.log" 2>/dev/null || true
cp "$smoke_log" "$ART_DIR/smoke.log" 2>/dev/null || true
( cd "$ART_DIR" && sha256sum -- "./$(ls *.whl | sed -n '1p')" >sha256sums.txt )
ls -l "$ART_DIR"
du -sh "$ART_DIR"
echo "PASS: Faust 源码编译完成，全部产物在 $ART_DIR"
