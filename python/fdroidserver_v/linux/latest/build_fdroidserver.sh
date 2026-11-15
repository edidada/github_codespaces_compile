#! /usr/bin/env bash
#
# F-Droid Server（fdroidserver）源码编译：Python 包，按上游自己的发布路径出 sdist（顺带
# 试 wheel），再在干净 venv 里 pip install 这个 tar.gz，最后用 `fdroid version` 当活体证据。
#
# 上游：https://gitlab.com/fdroid/fdroidserver
# 实测基准（2026-10-26，tag 2.4.5）：
#   setup.py            -> version='2.4.5'（字面写在 setup.py 里，不是从 git describe 推的）
#   setup.py            -> python_requires='>=3.9'
#   setup.py            -> entry_points={'console_scripts': ['fdroid=fdroidserver.__main__:main']}
#   setup.py            -> setup_requires=['babel']（装 babel 到 venv 里，别让它去 easy_install）
#   classifiers         -> 官方声称支持 Python 3.9 / 3.10 / 3.11 / 3.12 / 3.13 / 3.14
#   data_files          -> 从 MANIFEST.in 里正则抓 locale/*.po 对应的 *.mo，所以缺 .mo 会抖
#   .gitlab-ci.yml:191-205 -> 上游发布流程：python3 -m venv sdist-env; ./setup.py sdist;
#                              $pip install dist/fdroidserver-*.tar.gz
#
# 三个坑：
#   A) 上游只发 sdist（./setup.py sdist），不是 python -m build 的双产物。所以这里先试
#      `python -m build`（sdist+wheel），失败就退回 `python -m build --sdist`，判据落在
#      "有 sdist 且能被 venv 装起来"——和上游 CI 的判据一致，不自创标准。
#   B) install_requires 里有一串有年头/有平台的包（clint、oscrypto、ruamel.yaml<0.17.22、
#      androguard、apache-libcloud...）。老 Python 上装得动，新 Python（比如 ubuntu-26.04
#      自带的 3.1x）不一定。所以"带依赖完整安装 + fdroid version"能成就当硬门槛，
#      装不上就 WARN 并把真正失败的那个分发名打出来，同时退回 --no-deps 装 + import 校验，
#      产物本身坏没坏要说得清。
#   C) PEP 668：Ubuntu 24.04/26.04 的系统 python 带 EXTERNALLY-MANAGED，直接 pip install 会被拦，
#      所以全程在 venv 里跑，不碰系统站点目录。
#
# bash 兼容：不用 mapfile / ${v,,} / 关联数组；版本比较用纯 bash（见 fd_ver_newer）。
set -euo pipefail

# ==== 版本相关：固定版本分支只需要改这一行 ====
FDROID_TAG="${FDROID_TAG:-}"

FDROID_GIT_URL="${FDROID_GIT_URL:-https://gitlab.com/fdroid/fdroidserver.git}"
WORK_DIR="${WORK_DIR:-$(pwd)/_fdroid_build}"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/fdroidserver"

fd_die() {
    echo "FATAL: $*" >&2
    exit 1
}

# $1 比 $2 新 -> 0。只用点分数字，够本系列用了。
fd_ver_newer() {
    local -a xa=()
    local -a ya=()
    IFS=. read -r -a xa <<<"$1"
    IFS=. read -r -a ya <<<"$2"
    local n=${#xa[@]}
    if [ ${#ya[@]} -gt "$n" ]; then n=${#ya[@]}; fi
    local i=0 a b
    while [ "$i" -lt "$n" ]; do
        a="${xa[$i]:-0}"
        b="${ya[$i]:-0}"
        a="${a%%[!0-9]*}"
        b="${b%%[!0-9]*}"
        a="${a:-0}"
        b="${b:-0}"
        if [ "$((10#$a))" -gt "$((10#$b))" ]; then return 0; fi
        if [ "$((10#$a))" -lt "$((10#$b))" ]; then return 1; fi
        i=$((i + 1))
    done
    return 1
}

echo "==== 0. 宿主环境 ===="
uname -a
if [ -r /etc/os-release ]; then
    sed -n 's/^PRETTY_NAME=//p' /etc/os-release | sed -n '1p' | tr -d '"'
fi
PYBIN=""
for c in python3 python; do
    if command -v "$c" >/dev/null 2>&1; then PYBIN="$c"; break; fi
done
[ -n "$PYBIN" ] || fd_die "找不到 python3/python"
PYVER="$("$PYBIN" -c 'import sys;print(".".join(str(x) for x in sys.version_info[:3]))')"
echo "python: $PYBIN $PYVER（上游 setup.py 声称 python_requires>=3.9）"
"$PYBIN" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)' \
    || fd_die "Python $PYVER < 3.9，不满足 setup.py 的 python_requires"

echo "==== 1. 依赖 ===="
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    # python3-venv：没有它 venv 起不来（坑 C）；build-essential/python3-dev：
    # install_requires 里 Pillow/lxml 这类要编译时就靠它们（有 wheel 时用不上）
    sudo apt-get install -y -qq git curl ca-certificates python3-venv python3-pip build-essential python3-dev || \
        sudo apt-get install -y -qq git curl ca-certificates python3-venv python3-pip
fi
command -v git >/dev/null 2>&1 || fd_die "缺 git"
"$PYBIN" -m venv --help >/dev/null 2>&1 || fd_die "这台的 python 不带 venv 模块（apt 装 python3-venv）"

echo "==== 2. 取源码 ===="
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

if [ -z "$FDROID_TAG" ]; then
    echo "---- 解析上游最新正式 tag ----"
    git ls-remote --tags "$FDROID_GIT_URL" \
        | sed -n 's#.*refs/tags/\([^{}]*\)$#\1#p' \
        | grep -E '^[0-9]+(\.[0-9]+)+$' >"$WORK_DIR/tags.txt" || true
    if [ ! -s "$WORK_DIR/tags.txt" ]; then
        fd_die "从 $FDROID_GIT_URL 的 tag 里挑不出纯数字版本"
    fi
    echo "INFO: 候选 tag：$(tr '\n' ' ' <"$WORK_DIR/tags.txt")"
    best=""
    while IFS= read -r t; do
        if [ -z "$best" ] || fd_ver_newer "$t" "$best"; then best="$t"; fi
    done <"$WORK_DIR/tags.txt"
    FDROID_TAG="$best"
    echo "INFO: latest 解析结果 = $FDROID_TAG"
else
    echo "INFO: 固定版本 = $FDROID_TAG"
fi

git clone --quiet --depth=1 --branch "$FDROID_TAG" "$FDROID_GIT_URL" "$SRC_DIR" \
    || fd_die "git clone 失败：$FDROID_GIT_URL @ $FDROID_TAG"
cd "$SRC_DIR"
head_tag="$(git describe --tags --exact-match HEAD 2>/dev/null || true)"
[ "$head_tag" = "$FDROID_TAG" ] || fd_die "HEAD 的 tag 是 '$head_tag'，不是预期的 $FDROID_TAG"
echo "PASS: 源码就位，tag=$FDROID_TAG commit=$(git rev-parse --short HEAD)"

# setup.py 里的 version= 必须等于 tag（上游是字面写的，这就是版本串的身份证）
setup_ver="$(sed -n "s/^[[:space:]]*version=['\"]\\([^'\"]*\\)['\"].*/\\1/p" setup.py | sed -n '1p')"
[ -n "$setup_ver" ] || fd_die "setup.py 里解析不到 version="
[ "$setup_ver" = "$FDROID_TAG" ] || fd_die "setup.py version=$setup_ver 和 tag $FDROID_TAG 不一致（上游没同步抬版本？）"
echo "PASS: setup.py version = $setup_ver（与 tag 一致）"

echo "==== 3. 干净 venv ===="
VENV="$WORK_DIR/venv"
"$PYBIN" -m venv "$VENV"
VPY="$VENV/bin/python"
[ -x "$VPY" ] || VPY="$VENV/Scripts/python.exe"
[ -x "$VPY" ] || fd_die "venv 里找不到 python"
"$VPY" -m pip install --upgrade pip >"$LOG_DIR/pip-upgrade.log" 2>&1 || tail -n 20 "$LOG_DIR/pip-upgrade.log"
# build 是打包器；babel 是 setup.py 的 setup_requires（不装的话 setuptools 会去 easy_install）
"$VPY" -m pip install build babel setuptools wheel >"$LOG_DIR/pip-build-deps.log" 2>&1 || {
    tail -n 20 "$LOG_DIR/pip-build-deps.log"
    fd_die "venv 里装 build/babel 失败，没法打包"
}
echo "INFO: venv python = $("$VPY" --version)"

echo "==== 4. 打包 ===="
build_log="$LOG_DIR/python-build.log"
packaged=0
if "$VPY" -m build >"$build_log" 2>&1; then
    echo "PASS: python -m build（sdist + wheel）成功"
    packaged=1
else
    echo "---- $build_log 末尾 40 行 ----"
    tail -n 40 "$build_log"
    echo "WARN: python -m build 双产物没走通，退回上游自己的路子：只做 sdist（坑 A）"
    if "$VPY" -m build --sdist >>"$build_log" 2>&1; then
        echo "PASS: python -m build --sdist 成功（与上游 .gitlab-ci.yml:193 ./setup.py sdist 同效）"
        packaged=1
    else
        tail -n 40 "$build_log"
        fd_die "连 sdist 都打不出来，fdroidserver $FDROID_TAG 打包失败"
    fi
fi
[ "$packaged" = 1 ] || fd_die "没打包成功"

sdists="$(find dist -maxdepth 1 -name 'fdroidserver-*.tar.gz' -type f | sort)"
wheels="$(find dist -maxdepth 1 -name 'fdroidserver-*.whl' -type f | sort)"
[ -n "$sdists" ] || fd_die "dist/ 里没有 fdroidserver-*.tar.gz"
echo "INFO: sdist  = $(echo "$sdists" | tr '\n' ' ')"
echo "INFO: wheel  = $(if [ -n "$wheels" ]; then echo "$wheels" | tr '\n' ' '; else echo '（没出 wheel，上游本来也只发 sdist）'; fi)"

echo "---- sdist 内容校验 ----"
sdist_first="$(echo "$sdists" | sed -n '1p')"
sdist_list="$("$VPY" -c 'import sys,tarfile
with tarfile.open(sys.argv[1]) as t:
    names = sorted(m.name for m in t.getmembers())
print("\n".join(names))' "$sdist_first")"
for need in setup.py pyproject.toml fdroidserver/__main__.py MANIFEST.in; do
    case "
$sdist_list
" in
        *"/$need
"*) echo "PASS: sdist 里有 $need" ;;
        *) fd_die "sdist 里缺 $need" ;;
    esac
done
echo "INFO: sdist 成员数 $(printf '%s\n' "$sdist_list" | grep -c . )"

if [ -n "$wheels" ]; then
    echo "---- wheel 内容校验 ----"    # shellcheck disable=SC2086
    "$VPY" - "$wheels" <<'PY'
import sys, zipfile
for whl in sys.argv[1:]:
    with zipfile.ZipFile(whl) as z:
        names = z.namelist()
    need = ['fdroidserver/__main__.py']
    for n in need:
        assert n in names, (whl, 'missing ' + n)
    ep = [n for n in names if n.endswith('entry_points.txt')]
    assert ep, (whl, 'no entry_points.txt')
    with zipfile.ZipFile(whl) as z:
        body = z.read(ep[0]).decode()
    assert 'fdroid' in body, (whl, 'console_scripts 里没有 fdroid：' + body)
    print('PASS: wheel %s（%d 个成员，entry_point 有 fdroid）' % (whl.split('/')[-1], len(names)))
PY
fi

echo "==== 5. 装起来跑一把（坑 B：装不上只 WARN，产物好坏另有判据）===="
install_log="$LOG_DIR/pip-install-wheel.log"
runtime_ok=0
if "$VPY" -m pip install "$sdist_first" >"$install_log" 2>&1; then
    echo "PASS: pip install $sdist_first（带依赖，和上游 CI :205 同一条命令）"
    runtime_ok=1
else
    echo "---- $install_log 里真正失败的环节 ----"
    grep -iE 'error|failed|ERROR: ' "$install_log" | tail -n 15 || true
    echo "WARN: 带依赖的完整安装在这台 $("$VPY" --version) 上没走通（上面是原因）"
fi

fdroid_bin="$VENV/bin/fdroid"
[ -x "$fdroid_bin" ] || fdroid_bin="$VENV/Scripts/fdroid.exe"
if [ "$runtime_ok" = 1 ]; then
    ver_out="$("$fdroid_bin" version 2>&1 || true)"
    echo "---- fdroid version ----"
    printf '%s\n' "$ver_out" | sed -n '1,12p'
    case "$ver_out" in
        *"$FDROID_TAG"*) echo "PASS: fdroid version 里报出 $FDROID_TAG" ;;
        *) fd_die "fdroid version 输出里没有 $FDROID_TAG：$ver_out" ;;
    esac
    "$VPY" -m pip check >"$LOG_DIR/pip-check.log" 2>&1 && echo "PASS: pip check 干净" \
        || { echo "WARN: pip check 有意见（依赖冲突不阻断构建）"; sed -n '1,10p' "$LOG_DIR/pip-check.log"; }
else
    # 退回 --no-deps：至少证明 wheel/sdist 里的包结构是完整可用的
    if "$VPY" -m pip install --no-deps "$sdist_first" >"$LOG_DIR/pip-install-nodeps.log" 2>&1; then
        echo "INFO: --no-deps 安装成功，退一步验包结构"
    else
        tail -n 20 "$LOG_DIR/pip-install-nodeps.log"
        fd_die "连 --no-deps 都装不上，产物本身有问题"
    fi
    # shellcheck disable=SC2086
    "$VPY" -c 'import fdroidserver, os; print("PASS: import fdroidserver ->", os.path.dirname(fdroidserver.__file__))' \
        || fd_die "import fdroidserver 失败"
    echo "WARN: 没跑成 fdroid version（缺运行时依赖），本轮只给包级结论"
fi

echo "==== 6. 归档 ===="
cp dist/* "$ART_DIR/" 2>/dev/null || true
cp "$build_log" "$ART_DIR/python-build.log" 2>/dev/null || true
{
    echo "fdroidserver $FDROID_TAG"
    echo "commit: $(git rev-parse HEAD)"
    echo "python: $PYVER  ($("$VPY" --version))"
    echo "host: $(uname -s)/$(uname -m)  $(sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | tr -d '\"')"
    echo "sdist: $(echo "$sdists" | tr '\n' ' ')"
    echo "wheel: $(if [ -n "$wheels" ]; then echo "$wheels" | tr '\n' ' '; else echo none; fi)"
    echo "runtime_gate: $(if [ "$runtime_ok" = 1 ]; then echo 'fdroid version 通过'; else echo '仅包级校验（见 WARN）'; fi)"
} >"$ART_DIR/BUILD_INFO.txt"
if command -v sha256sum >/dev/null 2>&1; then
    ( cd "$ART_DIR" && sha256sum -- fdroidserver-* >sha256sums.txt )
fi
ls -l "$ART_DIR"

host_os="$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | sed -n '1p' | tr -d '"')"
echo "PASS: fdroidserver $FDROID_TAG 在 ${host_os:-$(uname -s)}（Python $PYVER）上完成打包与校验"
