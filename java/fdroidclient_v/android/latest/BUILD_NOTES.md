# F-Droid 客户端（fdroidclient）安卓产物构建说明

上游仓库：<https://gitlab.com/fdroid/fdroidclient>（命名空间是 `fdroid`，不是 `f-droid`；
用 `gitlab.com/api/v4/projects/f-droid%2Ffdroidclient/...` 取文件会直接 404，这是踩过的）

脚本：`build_fdroidclient.sh`（与 `java/fdroidclient_v/linux/latest/` 同一份，
宿主同样是 Ubuntu，编译命令就是官方文档给的 `./gradlew assembleDebug`）
分支：`java/fdroidclient_v/android/latest`（本目录），对应 workflow
`java_fdroidclient_v_android_latest.yml`

## 与 linux/latest 的关系

两条腿跑的是同一个脚本、同一套校验：

| | linux/latest | android/latest（本目录） |
|---|---|---|
| 编译宿主 | ubuntu-22.04 / 24.04 / 26.04（三腿矩阵） | ubuntu-22.04（单腿，对齐 zxing / ml_kit 的 android 系列） |
| OS 列含义 | 编译宿主 = Linux | 产物目标平台 = Android（APK 由 `app/build.gradle.kts` 决定 minSdk=24 / targetSdk=37） |
| 产物 | `_fdroid_build/artifacts/` 下 4 个 APK + summary.tsv + sha256sums.txt | 同左，workflow artifact 名 `fdroidclient-android-ubuntu-22.04` |
| JDK | 21（上游 `.gitlab-ci.yml` 钉 java-21） | 同左 |

四个已知坑与刻意的判据（flavor 矩阵出多个 APK、debug 包名只断言 `org.fdroid` 前缀、
compileSdk 37 靠 AGP 兜底、LFS/子模块按上游 CI 显式跳过）详见
`java/fdroidclient_v/linux/latest/BUILD_NOTES.md`，不在本文件重复。

硬门槛也同 linux 版：至少 1 个 APK，每个 > 1 MiB、zip 完整、含 classes*.dex /
AndroidManifest.xml / resources.arsc，aapt2 badging 包名以 org.fdroid 开头。
