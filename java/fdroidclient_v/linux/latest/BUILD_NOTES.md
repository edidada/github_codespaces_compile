# F-Droid 客户端（fdroidclient）源码编译说明

上游仓库：<https://gitlab.com/fdroid/fdroidclient>（注意命名空间是 `fdroid`，不是 `f-droid`；
用 `gitlab.com/api/v4/projects/f-droid%2Ffdroidclient/...` 取文件会直接 404，这是踩过的）

脚本：`build_fdroidclient.sh`
分支：`java/fdroidclient_v/linux/latest`（本目录），对应 workflow
`java_fdroidclient_v_linux_latest.yml`

## 用户给的官方命令就是本脚本的主命令

F-Droid 官方文档（<https://f-droid.org/docs/Building_From_Source/>）给客户端的构建方式是

```sh
# Linux / macOS
./gradlew assembleDebug

# Windows
gradlew.bat assembleDebug
```

本脚本执行的正是 `./gradlew --no-daemon --console=plain --stacktrace assembleDebug`，
没有自己发明 target，也没有改成 `build`（`build` 会额外跑 lint/test，CI 里没必要）。

## 为什么铺 Linux / Windows / macOS 三个宿主

用户文档明确写了 Linux/macOS 与 Windows 两条命令，Gradle wrapper 本身跨平台，Android SDK
三平台都有官方发行，所以三档都铺得开（与 SeaBIOS 系列"只能 Linux"的结论不同，那边的判据是
Makefile 里的 `-m32/-melf_i386`）。三腿各自的源目录：

| 宿主 | 源分支目录 | runner matrix |
|---|---|---|
| Linux | `java/fdroidclient_v/linux/<ver>` | ubuntu-22.04 / ubuntu-24.04 / ubuntu-26.04 |
| Windows | `java/fdroidclient_v/windows/<ver>` | windows-2022 / windows-2025 |
| macOS | `java/fdroidclient_v/macos/<ver>` | macos-14 / macos-latest |

"支持 OS 版本"要分两层看，别混：

1. **编译宿主**：就是上面三档 runner，由本流水线实测。
2. **运行目标（Android 版本）**：`app/build.gradle.kts:20-21` 写死 `minSdk = 24`、
   `targetSdk = 37`，即产出的 APK 面向 Android 7.0 及以上；这不是本流水线编出来的东西，
   是 APK 里 `aapt2 dump badging` 会打印的 `sdkVersion`/`targetSdkVersion`，脚本已经把它抄进日志。

## 上游构建环境的实测数据（2026-10-26，tag 2.0.2）

| 事实 | 出处 |
|---|---|
| Gradle wrapper `gradle-9.4.1-all`，且钉了 `distributionSha256Sum` | `gradle/wrapper/gradle-wrapper.properties` |
| `compileSdk = "37"`，AGP `9.2.1`，Kotlin `2.4.0`，Compose BOM `2026.06.00` | `gradle/libs.versions.toml` |
| `minSdk = 24`，`targetSdk = 37`，`namespace = "org.fdroid"` | `app/build.gradle.kts:15-21` |
| 上游 CI 用 JDK 21（`JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64`） | `.gitlab-ci.yml` `.base.variables` |
| 上游 CI 设 `GIT_LFS_SKIP_SMUDGE=1`、`GIT_SUBMODULE_STRATEGY: none` | `.gitlab-ci.yml` `.base.variables` |
| 上游 CI 的 SDK 装法：从 `libs.versions.toml` sed 出 compileSdk，再 `sdkmanager --install "build-tools;${SDK}.0.0" "platform-tools" "platforms;android-${SDK}"` | `.gitlab-ci.yml` `.base.before_script` |
| 唯一子模块是 `fastlane`（指向 fdroidclient-fastlane），与编译无关 | `.gitmodules` |
| flavor 矩阵：`flavorDimensions += listOf("variant","release")`，variant 有 basic/full，release 有 default/nightly | `app/build.gradle.kts:51-66` |

脚本照搬上游 CI 的装包方式（包括从 `libs.versions.toml` 现读 compileSdk），
所以不hardcode SDK 版本，上游抬 `compileSdk` 时这边自动跟上。

## 四个坑（脚本注释里也写了一份）

1. **一次出 4 个 APK**。`assembleDebug` 走 flavor 矩阵，产物在
   `app/build/outputs/apk/<变体>Debug/*.apk`。校验按"至少 1 个 + 逐个验活"写，
   不写死数量，否则上游砍一个 flavor 就假失败。
2. **包名/版本名带后缀**。debug 贴 `.debug`（`:46`）和 `-<gitHash>-debug`（`:47`），
   flavor 各贴 `.basic`/`.fdroid`/`.nightly`。所以 badging 只能断言包名以 `org.fdroid` 开头、
   `versionName` 以本次 tag 开头，不能断言精确串。
3. **`compileSdk = 37` 这种新平台未必立刻进稳定通道**。`sdkmanager --install` 失败只 WARN，
   兜底是 AGP 自己的 SDK 自动下载（前提是 licenses 已接受，脚本先跑 `yes | sdkmanager --licenses`）。
   判据是编出来的 APK，不是 sdkmanager 的退出码。
4. **LFS + 子模块**。仓库有 `.gitattributes` 走 LFS；上游 CI 显式跳过。镜像上没装 git-lfs 时
   filter 根本不注册，效果和 `GIT_LFS_SKIP_SMUDGE=1` 一样（素材留指针），编译不受影响。

## 硬门槛（任一不过就 FATAL）

- `git describe --tags --exact-match HEAD` 必须等于本次 tag；
- `gradlew assembleDebug` 退出码 0；
- 至少 1 个 APK，且每个：> 1 MiB、`unzip -t` 通过、含 `classes*.dex` /
  `AndroidManifest.xml` / `resources.arsc`；
- 有 aapt2 时：`package: name=` 以 `org.fdroid` 开头，`versionName` 以本次 tag 开头；
  拿不到 aapt2 只 WARN（build-tools 没装上的时候仍能靠前面的结构校验给出结论）。

产物落到 `_fdroid_build/artifacts/`（`fdroidclient-<tag>-<变体>-debug.apk` +
`summary.tsv` + `sha256sums.txt` + gradle 日志），由 workflow 用
`actions/upload-artifact@v4` 上传成 `fdroidclient-<runner>`。

## bash 兼容

macOS 腿的系统 `/bin/bash` 是 3.2，所以脚本避开了 `mapfile`、`${v,,}`、关联数组，
`sort -V` 也只做兜底（BSD sort 不认），版本比较用纯 bash 的 `fd_newer`，
本地对 `2.0.2 / 2.0.1 / 10.0 / 2.0.10 / 2.1` 这些组合核过。
