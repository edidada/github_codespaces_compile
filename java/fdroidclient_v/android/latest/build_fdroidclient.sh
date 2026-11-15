#! /usr/bin/env bash
#
# F-Droid 客户端（fdroidclient）源码编译：从 GitLab 取上游 tag，跑上游文档里那条
# 官方命令 `./gradlew assembleDebug`，再把产出的每个 APK 逐个验活（zip 完整性 /
# classes.dex / AndroidManifest.xml / aapt2 badging 里的包名与版本串）。
#
# 上游：https://gitlab.com/fdroid/fdroidclient
# 官方构建说明：README「Building」+ 用户文档 https://f-droid.org/docs/Building_From_Source/
# 实测基准（2026-10-26，tag 2.0.2）：
#   gradle/wrapper/gradle-wrapper.properties -> gradle-9.4.1-all
#   gradle/libs.versions.toml               -> compileSdk = "37"，AGP 9.2.1，Kotlin 2.4.0
#   app/build.gradle.kts:20-21              -> minSdk = 24，targetSdk = 37
#   .gitlab-ci.yml（上游自己的 CI）           -> JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
#                                                GIT_LFS_SKIP_SMUDGE=1
#                                                GIT_SUBMODULE_STRATEGY: none
#   上游 CI 的装包方式：从 libs.versions.toml 里 sed 出 compileSdk，再
#   sdkmanager --install "build-tools;${SDK}.0.0" "platform-tools" "platforms;android-${SDK}"
#   —— 本脚本照搬这一套，不自己发明版本号。
#
# 四个必须知道的坑（都来自上游文件，不是猜的）：
#   A) flavor 是个矩阵：app/build.gradle.kts:51 flavorDimensions += listOf("variant","release")，
#      variant 有 basic/full，release 有 default/nightly。所以 assembleDebug 不止出一个 APK，
#      而是 4 个（basicDefaultDebug / fullDefaultDebug / basicNightlyDebug / fullNightlyDebug）。
#      判据按"至少 1 个、逐个验活"来写，别把数量写死——上游哪天砍掉一个 flavor 就假失败了。
#   B) debug 版会往 applicationId 后面贴 .debug（:46），versionName 贴 "-<gitHash>-debug"（:47），
#      且 flavor 还各贴一段后缀（basic/full/nightly）。所以 badging 里的包名是
#      org.fdroid.debug.basic 之类，只能断言"以 org.fdroid 开头"，别断言精确串。
#   C) compileSdk = 37 这种新平台不一定立刻进 SDK 稳定通道。sdkmanager 装不上只 WARN，
#      兜底是 AGP 自己的 SDK 自动下载（前提 licenses 已接受，本脚本会先 yes | sdkmanager --licenses）。
#      真正的判据是编出来的 APK，不是 sdkmanager 的退出码。
#   D) 仓库走 git LFS，且有个和编译无关的子模块 fastlane（.gitmodules 里唯一一条，
#      指向上游 fdroidclient-fastlane）。上游 CI 显式跳过两者，本脚本同样：设
#      GIT_LFS_SKIP_SMUDGE=1、不做 submodule init。镜像上没装 git-lfs 时 filter 根本不注册，
#      结果一样（素材留指针），不影响编译。
#
# bash 兼容：本系列有 macOS 腿，系统 /bin/bash 是 3.2，所以这里不用 mapfile / ${v,,} /
# 关联数组，版本比较用纯 bash 实现（fd_newer）。
set -euo pipefail

# ==== 版本相关：固定版本分支只需要改这一行 ====
# 留空 = 自动取上游最新的纯数字 tag（latest 分支用）；固定版本分支写死，例如 FDROID_TAG="2.0.2"。
FDROID_TAG="${FDROID_TAG:-}"

FDROID_GIT_URL="${FDROID_GIT_URL:-https://gitlab.com/fdroid/fdroidclient.git}"
WORK_DIR="${WORK_DIR:-$(pwd)/_fdroid_build}"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/fdroidclient"

fd_die() {
    echo "FATAL: $*" >&2
    exit 1
}

# $1 比 $2 新 -> 返回 0；否则返回 1。只认点分数字，够用了（上游 tag 形如 2.0.2）。
# 注意：macOS 腿的系统 bash 是 3.2，所以这里用 read -a + 普通 while，不用 mapfile / 关联数组。
fd_newer() {
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
else
    sw_vers 2>/dev/null || true
fi
echo "bash: $BASH_VERSION"
echo "host: $(uname -s)/$(uname -m)"
if command -v java >/dev/null 2>&1; then
    java -version 2>&1 | sed -n '1p'
else
    fd_die "找不到 java：F-Droid 客户端要 JDK 21（上游 .gitlab-ci.yml 钉的就是 openjdk-21），请检查 workflow 里的 setup-java"
fi
SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
[ -n "$SDK_ROOT" ] || fd_die "ANDROID_HOME / ANDROID_SDK_ROOT 都没设：装个 Android SDK（workflow 里用 android-actions/setup-android）"
[ -d "$SDK_ROOT" ] || fd_die "ANDROID_HOME 指向的目录不存在：$SDK_ROOT"
echo "ANDROID_HOME=$SDK_ROOT"

echo "==== 1. 依赖 ===="
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq git curl unzip ca-certificates
elif command -v brew >/dev/null 2>&1; then
    for p in git curl unzip; do
        if ! command -v "$p" >/dev/null 2>&1; then
            brew install "$p" || echo "WARN: brew install $p 没成功，靠镜像自带的版本"
        fi
    done
fi
for p in git curl unzip; do
    command -v "$p" >/dev/null 2>&1 || fd_die "缺少 $p"
done
echo "git: $(git --version | sed -n '1p')"

echo "==== 2. 取源码 ===="
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"
export GIT_LFS_SKIP_SMUDGE=1
echo "INFO: GIT_LFS_SKIP_SMUDGE=$GIT_LFS_SKIP_SMUDGE（坑 D，照抄上游 CI）"

if [ -z "$FDROID_TAG" ]; then
    echo "---- 解析上游最新正式 tag ----"
    # 上游 tag 形态：2.0.2 / 2.0-rc1 / 2.0-alpha11。只收纯数字点分版本，rc/alpha 丢掉。
    git ls-remote --tags "$FDROID_GIT_URL" \
        | sed -n 's#.*refs/tags/\([^{}]*\)$#\1#p' \
        | grep -E '^[0-9]+(\.[0-9]+)+$' >"$WORK_DIR/tags.txt" || true
    if [ ! -s "$WORK_DIR/tags.txt" ]; then
        fd_die "从 $FDROID_GIT_URL 的 tag 里挑不出纯数字版本"
    fi
    echo "INFO: 候选 tag：$(tr '\n' ' ' <"$WORK_DIR/tags.txt")"
    best=""
    while IFS= read -r t; do
        if [ -z "$best" ] || fd_newer "$t" "$best"; then
            best="$t"
        fi
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

if [ -f .gitmodules ]; then
    echo "INFO: 有子模块但按上游 CI 的做法不初始化（坑 D）："
    sed -n '1,8p' .gitmodules
fi

# 上游自己也是从 libs.versions.toml 里读 compileSdk，不硬编码
COMPILE_SDK="$(sed -n 's/^[[:space:]]*compileSdk[[:space:]]*=[[:space:]]*"\([0-9][0-9]*\)".*/\1/p' gradle/libs.versions.toml | sed -n '1p')"
[ -n "$COMPILE_SDK" ] || fd_die "gradle/libs.versions.toml 里解析不到 compileSdk"
MIN_SDK="$(sed -n 's/.*minSdk[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' app/build.gradle.kts | sed -n '1p')"
TARGET_SDK="$(sed -n 's/.*targetSdk[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' app/build.gradle.kts | sed -n '1p')"
GRADLE_VER="$(sed -n 's/.*gradle-\([0-9][0-9.]*\)-\(all\|bin\)\.zip.*/\1/p' gradle/wrapper/gradle-wrapper.properties | sed -n '1p')"
echo "INFO: compileSdk=$COMPILE_SDK minSdk=${MIN_SDK:-?} targetSdk=${TARGET_SDK:-?} gradle=${GRADLE_VER:-?}"
echo "---- gradle wrapper 校验和（上游钉了 distributionSha256Sum，别自己关）----"
grep -E 'distributionUrl|distributionSha256Sum' gradle/wrapper/gradle-wrapper.properties || true

echo "==== 3. Android SDK 组件（照上游 CI 的装法，装不上只 WARN）===="
sdkmanager_bin=""
for c in "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" "$SDK_ROOT/tools/bin/sdkmanager" \
         "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager.bat" "$SDK_ROOT/tools/sdkmanager.bat"; do
    if [ -f "$c" ]; then sdkmanager_bin="$c"; break; fi
done
if [ -n "$sdkmanager_bin" ]; then
    echo "sdkmanager: $sdkmanager_bin"
    yes 2>/dev/null | "$sdkmanager_bin" --licenses >/dev/null 2>&1 || echo "WARN: licenses 批量接受没走通（可能已经接受过）"
    pkg_ok=1
    for pkg in "platform-tools" "platforms;android-$COMPILE_SDK" "build-tools;$COMPILE_SDK.0.0"; do
        if ! "$sdkmanager_bin" --install "$pkg" >"$LOG_DIR/sdkmanager.log" 2>&1; then
            echo "WARN: sdkmanager --install '$pkg' 失败（坑 C），交给 AGP 自动下载兜底"
            tail -n 5 "$LOG_DIR/sdkmanager.log" || true
            pkg_ok=0
        else
            echo "PASS: 已装 $pkg"
        fi
    done
    [ "$pkg_ok" = 1 ] || echo "INFO: 有组件没装上；若 AGP 也拿不到，编译阶段会以 FATAL 形式暴露"
else
    echo "WARN: 没找到 sdkmanager，完全依赖 AGP 自动下载 SDK（licenses 得由 workflow 预先接受）"
fi

echo "==== 4. 编译：./gradlew assembleDebug ===="
[ -f gradlew ] || fd_die "仓库里没有 gradlew"
chmod +x gradlew 2>/dev/null || true
build_log="$LOG_DIR/gradle-assembleDebug.log"
# --no-daemon：CI 一次性进程，留着 daemon 只是占内存；--console=plain：日志好贴
if ! ./gradlew --no-daemon --console=plain --stacktrace assembleDebug >"$build_log" 2>&1; then
    echo "---- $build_log 末尾 100 行 ----"
    tail -n 100 "$build_log"
    fd_die "F-Droid 客户端 $FDROID_TAG 编译失败（gradlew assembleDebug）"
fi
grep -E '^BUILD (SUCCESSFUL|FAILED)' "$build_log" | tail -n 1 || true
echo "INFO: gradle 任务耗时行：$(grep -E 'BUILD SUCCESSFUL in' "$build_log" | tail -n 1 | sed 's/^ *//')"

echo "==== 5. 产物验活 ===="
apk_list="$WORK_DIR/apks.txt"
find app/build/outputs/apk -type f -name '*.apk' | sort >"$apk_list"
apk_count="$(wc -l <"$apk_list" | tr -d ' ')"
[ "$apk_count" -ge 1 ] || {
    echo "---- app/build/outputs 目录树 ----"
    find app/build/outputs -maxdepth 3 -type d | sort | head -n 30
    fd_die "assembleDebug 没产出任何 APK"
}
echo "INFO: 产出 $apk_count 个 APK（坑 A：flavor 矩阵，上游改了数量也算正常）"

# aapt2：build-tools 里挑一个能用的。BSD sort（macOS 腿）没有 -V，所以只做字典序兜底，
# build-tools 版本号都是 a.b.c 形态，字典序够用。
aapt2=""
if [ -d "$SDK_ROOT/build-tools" ]; then
    for e in $(ls -1 "$SDK_ROOT/build-tools" 2>/dev/null | sort | tail -n 3); do
        for f in "$SDK_ROOT/build-tools/$e/aapt2" "$SDK_ROOT/build-tools/$e/aapt2.exe"; do
            if [ -x "$f" ]; then aapt2="$f"; break 2; fi
        done
    done
fi
if [ -z "$aapt2" ]; then
    for f in "$SDK_ROOT"/build-tools/*/aapt2; do
        if [ -x "$f" ]; then aapt2="$f"; break; fi
    done
fi

: >"$WORK_DIR/table.tsv"
printf '%-16s %-40s %12s %s\n' "variant" "apk" "bytes" "badging"
while IFS= read -r apk; do
    [ -n "$apk" ] || continue
    variant="$(basename "$(dirname "$apk")")"
    base="$(basename "$apk")"
    sz="$(wc -c <"$apk" | tr -d ' ')"
    [ "$sz" -gt 1048576 ] || fd_die "[$variant] $base 只有 $sz 字节，不像个正经 APK"

    unzip -tq "$apk" >"$LOG_DIR/unzip-$variant.log" 2>&1 || {
        tail -n 20 "$LOG_DIR/unzip-$variant.log"
        fd_die "[$variant] $base zip 完整性校验失败"
    }
    listing="$(unzip -l "$apk")"
    case "$listing" in
        *classes*.dex*) ;;
        *) fd_die "[$variant] $base 里没有 classes*.dex" ;;
    esac
    case "$listing" in
        *AndroidManifest.xml*) ;;
        *) fd_die "[$variant] $base 里没有 AndroidManifest.xml" ;;
    esac
    case "$listing" in
        *resources.arsc*) ;;
        *) fd_die "[$variant] $base 里没有 resources.arsc" ;;
    esac

    badge="-"
    if [ -n "$aapt2" ]; then
        if "$aapt2" dump badging "$apk" >"$LOG_DIR/badging-$variant.log" 2>&1; then
            pkg="$(sed -n "s/.*package: name='\([^']*\)'.*/\1/p" "$LOG_DIR/badging-$variant.log" | sed -n '1p')"
            vname="$(sed -n "s/.*versionName='\([^']*\)'.*/\1/p" "$LOG_DIR/badging-$variant.log" | sed -n '1p')"
            vcode="$(sed -n "s/.*versionCode='\([^']*\)'.*/\1/p" "$LOG_DIR/badging-$variant.log" | sed -n '1p')"
            mins="$(sed -n "s/.*sdkVersion:'\([^']*\)'.*/\1/p" "$LOG_DIR/badging-$variant.log" | sed -n '1p')"
            tgts="$(sed -n "s/.*targetSdkVersion:'\([^']*\)'.*/\1/p" "$LOG_DIR/badging-$variant.log" | sed -n '1p')"
            case "$pkg" in
                org.fdroid*) ;;
                *) fd_die "[$variant] badging 包名 '$pkg' 不是 org.fdroid 开头" ;;
            esac
            # 坑 B：debug/flavor 都往后缀里加东西，所以只断言 versionName 以本 tag 开头
            case "$vname" in
                "$FDROID_TAG"*) ;;
                *) fd_die "[$variant] versionName '$vname' 对不上 tag $FDROID_TAG" ;;
            esac
            badge="pkg=$pkg versionName=$vname versionCode=${vcode:-?} sdk=${mins:-?}->${tgts:-?}"
            echo "PASS: [$variant] $base $badge"
        else
            echo "WARN: [$variant] aapt2 dump badging 失败，只做了 zip/dex/manifest 校验"
            tail -n 10 "$LOG_DIR/badging-$variant.log" || true
        fi
    else
        echo "WARN: 没找到 aapt2（build-tools 没装上？），跳过 badging 校验"
    fi
    printf '%s\t%s\t%s\t%s\n' "$variant" "$base" "$sz" "$badge" >>"$WORK_DIR/table.tsv"
done <"$apk_list"

echo "==== 6. 归档 ===="
cp "$apk_list" "$ART_DIR/apk-list.txt"
cp "$WORK_DIR/table.tsv" "$ART_DIR/summary.tsv"
cp "$LOG_DIR/gradle-assembleDebug.log" "$ART_DIR/gradle-assembleDebug.log" || true
while IFS= read -r apk; do
    [ -n "$apk" ] || continue
    variant="$(basename "$(dirname "$apk")")"
    cp "$apk" "$ART_DIR/fdroidclient-$FDROID_TAG-$variant-debug.apk"
done <"$apk_list"
if command -v sha256sum >/dev/null 2>&1; then
    ( cd "$ART_DIR" && sha256sum -- *.apk >sha256sums.txt )
elif command -v shasum >/dev/null 2>&1; then
    ( cd "$ART_DIR" && for f in *.apk; do printf '%s  %s\n' "$(shasum -a 256 "$f" | cut -d' ' -f1)" "$f"; done >sha256sums.txt )
fi
ls -l "$ART_DIR"

echo "---- 产物一览 ----"
cat "$ART_DIR/summary.tsv"

host_os="$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | sed -n '1p' | tr -d '"')"
[ -n "$host_os" ] || host_os="$(uname -s) $(uname -m)"
echo "PASS: F-Droid 客户端 $FDROID_TAG 在 $host_os 上完成 assembleDebug，$apk_count 个 APK 全部验活（compileSdk=$COMPILE_SDK，Android 支持 ${MIN_SDK:-?}->${TARGET_SDK:-?}）"
