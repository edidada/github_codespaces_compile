# Faust Python 流处理库源码编译说明

上游仓库：<https://github.com/faust-streaming/faust>（robinhood/faust 的维护
fork，"Python Stream Processing"，默认分支 master）

脚本：`get_faust.sh`
分支：`python/faust/linux/latest`（本目录），对应 workflow `python_faust_linux_latest.yml`

## 官方构建命令

README/docs 的源码构建即 setuptools 打包。setup.py 关键点：

- `use_scm_version=True` —— 版本号来自 **git tag**（setuptools_scm），
  所以脚本必须**完整克隆**（非 shallow），不能 `--depth=1`；
- `USE_CYTHON = os.environ.get("USE_CYTHON", True)` —— 默认把
  `faust/_cython/streams.pyx` **Cython 化编译成 C 扩展**（Linux 产物
  `faust/_cython/streams.cpython-3XX-x86_64-linux-gnu.so`）；
- `requires-python >= 3.10`，ubuntu-22.04 runner 自带 python3.10，无需额外装 Python。

脚本命令：

```
pip install build setuptools wheel cython setuptools_scm
python -m build --no-isolation --wheel
```

用 `--no-isolation` 是刻意的：隔离构建环境里若没有 Cython，
setup.py 的 `except ImportError` 会静默回落到纯 Python 模式——那样就
**没有编译 C 扩展**，与"源码编译"目标不符；no-isolation + 手动备齐依赖
保证 Cython 真的参与编译。

## 数据/事实

| 事实 | 出处 |
|---|---|
| 版本号走 setuptools_scm（git tag）→ 必须完整克隆 | setup.py `use_scm_version=True` + 注释 |
| 默认编译 `_cython/streams` C 扩展 | setup.py `USE_CYTHON` 默认 True、`ext_modules` |
| Windows 专属扩展 `faust/_cython/windows` 仅 win32 平台参与 | setup.py 平台判断 |
| requires-python >=3.10 | pyproject.toml |

## 硬门槛（任一不过就 FATAL）

- `python -m build --wheel` 退出码 0；
- 产出 `faust_streaming-*.whl`，且 wheel 内**必须含**
  `faust/_cython/streams.*.so`（证明 C 扩展真编译了）；
- venv 安装该 wheel 并 `import faust` 打印版本号成功。

产物落到 `_faust_build/artifacts/`（faust_streaming-*.whl + revision.txt +
build-wheel.log + smoke.log + sha256sums.txt），由 workflow 上传 artifact
`faust-ubuntu-22.04`。
