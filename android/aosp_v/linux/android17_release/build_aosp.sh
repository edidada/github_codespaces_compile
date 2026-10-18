#!/bin/bash
# AOSP 平台整体构建（repo init + repo sync + lunch + m）
#
# 这条分支和仓库里其它 build_*.sh 不一样：它跑不了 GitHub 托管 runner。
# 一次完整 sync（--depth=1，单分支）就要 250 GB 上下，后面 m 的 out/ 再加
# 150~200 GB；托管 runner 根盘只有 ~84 GB，单 job 上限 6 小时，
# 而 AOSP 全量构建在 32~64 核机器上通常要 2~6 小时（sync 另算 1~3 小时）。
# 所以 workflow 里 runs-on 用的是 self-hosted 标签，先跑 preflight 检查有没有
# 对应 runner，没有就把 build job 跳过（免得 job 一直卡在 waiting 状态）。
#
# 需要的 runner：
#   Linux x86_64（Ubuntu 22.04/24.04），>= 64 GB 空闲磁盘（脚本会实测），
#   >= 32 GB 内存，标签 label = aosp，能直连 android.googlesource.com
#   或走清华镜像（见 REPO_URL / MANIFEST_URL）。
set -euo pipefail

# 1. 可调参数（都在 workflow_dispatch / runner 的环境变量里可覆盖）
AOSP_BRANCH="${AOSP_BRANCH:-android17-release}"
# 上游从 2026 年起只在 Q2/Q4 往 AOSP 推源码，android-latest-release 永远指向
# 最新发布分支（当前是 android17-release）。这里写死具体分支是为了可复现，
# 想跟着最新走就把 AOSP_BRANCH 设成 android-latest-release。
BUILD_TARGET="${BUILD_TARGET:-aosp_cf_x86_64_phone-trunk_staging-userdebug}"
# Cuttlefish（aosp_cf_x86_64_phone）是 AOSP 官方推荐的「无真机也能跑」目标，
# 产物是可在云上启动的虚拟机镜像；换 aosp_arm64-userdebug 之类也行。
MANIFEST_URL="${MANIFEST_URL:-https://android.googlesource.com/platform/manifest}"
REPO_URL="${REPO_URL:-https://storage.googleapis.com/git-repo-downloads/repo}"
# 国内机器上把上面两个换成清华镜像：
#   MANIFEST_URL=https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest
#   REPO_URL=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo
JOBS="${JOBS:-}"            # 空 = 按 nproc 与内存自动收敛
SYNC_DEPTH="${SYNC_DEPTH:-1}" # 1 = shallow，能省一半以上磁盘
AOSP_WORK_DIR="${AOSP_WORK_DIR:-${RUNNER_WORKSPACE:-${HOME:-/tmp}}/aosp-build}"

echo "==== 构建参数 ===="
echo "AOSP_BRANCH  = ${AOSP_BRANCH}"
echo "BUILD_TARGET = ${BUILD_TARGET}"
echo "MANIFEST_URL = ${MANIFEST_URL}"
echo "REPO_URL     = ${REPO_URL}"
echo "WORK_DIR     = ${AOSP_WORK_DIR}"
echo "SYNC_DEPTH   = ${SYNC_DEPTH}"

# 2. 环境体检：宁可在这里明确失败，也不要让 repo sync 跑到一半把盘写爆。
[ "$(uname -s)" = "Linux" ] || { echo "FATAL: AOSP 全平台构建只能跑在 Linux 上" >&2; exit 1; }
[ "$(uname -m)" = "x86_64" ] || { echo "FATAL: 官方 prebuilts 只覆盖 x86_64 宿主，当前 $(uname -m)" >&2; exit 1; }

mkdir -p "${AOSP_WORK_DIR}"
WORK_REAL="$(cd "${AOSP_WORK_DIR}" && pwd)"
FREE_GB="$(df -BG --output=avail "${WORK_REAL}" | tail -1 | tr -dc '0-9')"
TOTAL_CPU="$(nproc)"
MEM_GB="$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo)"
echo "==== 机器 ===="
echo "CPU 核数     = ${TOTAL_CPU}"
echo "内存         = ${MEM_GB} GB"
echo "${WORK_REAL} 空闲磁盘 = ${FREE_GB} GB"
REQUIRED_GB=450
if [ "${FREE_GB}" -lt "${REQUIRED_GB}" ]; then
    echo "FATAL: 磁盘只剩 ${FREE_GB} GB，AOSP 全平台 sync+构建至少要 ${REQUIRED_GB} GB 空闲。" >&2
    echo "       （只想到源码这步的话 repo sync 约 250 GB，out/ 还要 150 GB 以上）" >&2
    exit 1
fi
if [ "${MEM_GB}" -lt 16 ]; then
    echo "WARN: 内存只有 ${MEM_GB} GB，soong 链接阶段很可能 OOM，仍在尝试。" >&2
fi

# 3. 依赖。托管 runner 上这些都有，自托管机器上缺啥补啥。
need=(git curl python3 unzip zip cpio rsync)
missing=()
for c in "${need[@]}"; do command -v "${c}" >/dev/null 2>&1 || missing+=("${c}"); done
if [ "${#missing[@]}" -gt 0 ]; then
    echo "==== 安装缺失依赖: ${missing[*]} ===="
    if command -v apt-get >/dev/null 2>&1; then
        SUDO=""; [ "$(id -u)" != 0 ] && SUDO="sudo"
        ${SUDO} apt-get update -y
        ${SUDO} apt-get install -y --no-install-recommends "${missing[@]}"
    else
        echo "FATAL: 缺少 ${missing[*]} 且没有 apt-get，请手工安装" >&2
        exit 1
    fi
fi
for c in "${need[@]}"; do command -v "${c}" >/dev/null 2>&1 || { echo "FATAL: ${c} 装完还是找不到" >&2; exit 1; }; done

# 4. repo 启动器。官方给的是 pip 包 / 直接下脚本，这里直接下脚本，
#    校验和由 repo 自己管理（REPO_URL 指向 git 仓库）。
mkdir -p "${HOME}/.bin"
if ! command -v repo >/dev/null 2>&1; then
    echo "==== 安装 repo 启动器 ===="
    curl -fsSL "${REPO_URL}/bin/repo" -o "${HOME}/.bin/repo"
    chmod +x "${HOME}/.bin/repo"
fi
export PATH="${HOME}/.bin:${PATH}"
repo --version | head -3 || true

# 构建并发度：lto/soong 阶段吃内存，按 4 GB/作业收敛。
if [ -z "${JOBS}" ]; then
    by_mem=$(( MEM_GB / 4 ))
    [ "${by_mem}" -lt 1 ] && by_mem=1
    JOBS="${TOTAL_CPU}"; [ "${by_mem}" -lt "${JOBS}" ] && JOBS="${by_mem}"
    [ "${JOBS}" -gt 32 ] && JOBS=32
fi
echo "JOBS         = ${JOBS}"

# 5. sync。已有 .repo 就增量，方便同一台 runner 反复跑。
cd "${WORK_REAL}"
if [ ! -d .repo ]; then
    echo "==== repo init ===="
    repo init -u "${MANIFEST_URL}" -b "${AOSP_BRANCH}" --repo-url="${REPO_URL}" \
        --depth="${SYNC_DEPTH}" --no-tags
else
    echo "==== 复用已有 .repo，切到 ${AOSP_BRANCH} ===="
    repo init -b "${AOSP_BRANCH}" --depth="${SYNC_DEPTH}" --no-tags || true
fi
echo "==== repo sync（这一步在首次构建时要几十分钟到几小时）===="
repo sync -c -j"${JOBS}" --no-tags --fail-fast --force-sync
repo forall -P -c 'echo "$projectpath $revision"' | head -5 || true
echo "==== 源码树体量 ===="
du -sh "${WORK_REAL}/.repo" 2>/dev/null | tail -1 || true
du -sh "${WORK_REAL}" | tail -1

# 6. 构建。envsetup.sh 里有 unbound variable 的老写法，这里临时放宽 -u。
set +u
source build/envsetup.sh
lunch "${BUILD_TARGET}"
set -u
BUILD_LOG="${WORK_REAL}/build-log.txt"
echo "==== m -j${JOBS} ===="
m -j"${JOBS}" 2>&1 | tee "${BUILD_LOG}" | tail -200 || {
    echo "FATAL: AOSP 构建失败，日志尾部：" >&2
    tail -60 "${BUILD_LOG}" >&2
    exit 1
}

# 7. 产物校验：镜像文件、版本号、out/ 体量。
set +u
PRODUCT_OUT="$(get_build_var PRODUCT_OUT)"
OUT_DIR="$(get_build_var OUT_DIR)"
PLATFORM_VERSION="$(get_build_var PLATFORM_VERSION)"
BUILD_NUMBER="$(get_build_var BUILD_NUMBER)"
TARGET_DEVICE="$(get_build_var TARGET_DEVICE)"
set -u
echo "==== 构建变量 ===="
echo "PLATFORM_VERSION = ${PLATFORM_VERSION}"
echo "BUILD_NUMBER     = ${BUILD_NUMBER}"
echo "TARGET_DEVICE    = ${TARGET_DEVICE}"
echo "PRODUCT_OUT      = ${PRODUCT_OUT}"
[ -d "${PRODUCT_OUT}" ] || { echo "FATAL: 找不到 ${PRODUCT_OUT}" >&2; exit 1; }

echo "==== 镜像 ===="
find "${PRODUCT_OUT}" -maxdepth 1 -name '*.img' -printf '%10s  %f\n' | sort -k2
[ -f "${PRODUCT_OUT}/system.img" ] || { echo "FATAL: 缺少 system.img" >&2; exit 1; }
[ -f "${PRODUCT_OUT}/super.img" ] || [ -f "${PRODUCT_OUT}/system.img" ] || {
    echo "WARN: 没有 super.img（分区组合方式随目标而变）" >&2; }
file "${PRODUCT_OUT}/system.img" || true

echo "==== 构建产物体量 ===="
du -sh "${WORK_REAL}/${OUT_DIR}" 2>/dev/null | tail -1 || du -sh "${WORK_REAL}/out" | tail -1

# Cuttlefish 目标可以直接起 VM：确认镜像工具在（不实际启动，CI 上没有 kvm 权限）
if [ -x "${WORK_REAL}/out/host/linux-x86/bin/launch_cvd" ]; then
    echo "launch_cvd 已产出（本机不启动，避免依赖 /dev/kvm）"
else
    echo "WARN: 没找到 out/host/linux-x86/bin/launch_cvd" >&2
fi

echo "完成：AOSP ${AOSP_BRANCH} / ${BUILD_TARGET} 全平台构建成功"
