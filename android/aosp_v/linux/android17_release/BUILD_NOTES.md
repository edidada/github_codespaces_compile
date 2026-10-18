# android/aosp_v/linux/android17_release

编译对象：**AOSP 平台整体**（不是某个 App，也不是 conscrypt 这类单仓库）。

## 版本依据

- Android 17 已于 2026-06 发布；自 2026 年起 Google 只在 Q2 / Q4 往 AOSP 推源码。
- `android-latest-release` 清单分支当前指向最新发布分支 `android17-release`
  （来源：source.android.com 的「网站更新」与「允许的 Android 16 版本字符串」页面，2026-09-18 更新）。
- 脚本把 `AOSP_BRANCH` 默认写成 `android17-release` 而不是 `android-latest-release`，
  为的是这条分支产出的东西可复现；想永远跟最新，就在 workflow_dispatch 里把
  `aosp_branch` 填成 `android-latest-release`。

## 构建方式

走官方 `repo` 流程，没有做任何「简化」：

```
repo init -u platform/manifest -b android17-release --depth=1 --no-tags
repo sync -c -j$JOBS --no-tags --fail-fast --force-sync
source build/envsetup.sh && lunch aosp_cf_x86_64_phone-trunk_staging-userdebug
m -j$JOBS
```

`aosp_cf_x86_64_phone` = Cuttlefish，AOSP 官方推荐的无真机目标，产物是能在云上启动的
x86_64 虚拟机镜像（system.img / vendor.img / super.img 等）。CI 里**不会**去 `launch_cvd`，
因为托管/自跑机器普遍没有 `/dev/kvm` 权限，只校验 `launch_cvd` 这个 host 工具是否产出。

`JOBS` 默认按 `内存/4` 和 `nproc` 取小、封顶 32 —— soong 的 lto 链接阶段很吃内存，
纯 `-j$(nproc)` 在 64 核 32 GB 的机器上容易 OOM。可用环境变量 `JOBS` 覆盖。

磁盘阈值定在 450 GB 空闲：`--depth=1` 的源码树约 250 GB，`out/` 再要 150 GB+。
不够就直接在 preflight 失败，不会让 `repo sync` 把盘写爆再报一个看不懂的错。

## 为什么这条不能用 ubuntu-24.04

GitHub 托管 runner：根盘约 84 GB（可用更少）、单 job 6 小时上限。
AOSP 全平台首次 sync 一般 1–3 小时，`m` 在 32–64 核机器上 2–6 小时，磁盘先爆。
所以 workflow 的 build job 用 `runs-on: [self-hosted, aosp]`，
并在它前面加了个跑在 ubuntu-24.04 上的 `preflight`：查询本仓库在线 runner 的标签，
没有 `aosp` 就把 build job 跳过（`if: needs.preflight.outputs.runner_found == 'true'`），
日志里打印注册 runner 的具体步骤。这样 push 触发也不会留一个永远 waiting 的 job。

## 验证内容

构建成功后脚本会打印并断言：

- `get_build_var PLATFORM_VERSION / BUILD_NUMBER / TARGET_DEVICE / PRODUCT_OUT / OUT_DIR`
- `PRODUCT_OUT` 下所有 `*.img` 的清单与大小；缺 `system.img` 直接 FATAL
- `file system.img`
- `out/` 总体量（`du -sh`）
- `out/host/linux-x86/bin/launch_cvd` 是否存在（缺失只告警）

## 已知限制

- 目前 `edidada/compiler_script` 仓库注册的 self-hosted runner 数量是 **0**
  （`gh api repos/edidada/compiler_script/actions/runners` → `total_count: 0`），
  edidada 是个人账号，没有 org 级 runner 可用。因此这条分支 push 后只会走到
  preflight → build skipped，直到有一台带 `aosp` 标签的在线机器为止。
- 本地开发机（Windows）访问不了 `android.googlesource.com`（443 直连超时），
  所以本分支的所有事实来自 source.android.com 文档与仓库 API，没有在本地预演过。
