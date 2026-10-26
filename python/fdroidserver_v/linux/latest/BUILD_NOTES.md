# F-Droid Server（fdroidserver）源码编译说明

上游：<https://gitlab.com/fdroid/fdroidserver>
脚本：`build_fdroidserver.sh`
分支：`python/fdroidserver_v/linux/latest`，workflow `python_fdroidserver_v_linux_latest.yml`

## 这个组件的"编译"是什么

fdroidserver 是纯 Python 包（`setup.py` + `pyproject.toml`），上游自己的发布路径就是打包 +
装起来跑，`.gitlab-ci.yml` 里逐条写着：

```
191:    - python3 -m venv sdist-env
192:    - . sdist-env/bin/activate
193:    - ./setup.py sdist
205:    - $pip install dist/fdroidserver-*.tar.gz
```

所以本脚本做的是：`python -m build`（sdist + wheel）→ 退回 `python -m build --sdist` 的容错
→ 干净 venv 里 `pip install dist/fdroidserver-*.tar.gz` → `fdroid version` 必须报出本次 tag。
不自创 `pytest`/`tox` 之类的判据。

## 支持 OS / 版本

| 层次 | 依据 |
|---|---|
| 打包机（本流水线实测） | ubuntu-22.04 / 24.04 / 26.04，Python 分别是 3.10 / 3.12 / 3.1x（各 runner 的实测版本会打进日志与 `BUILD_INFO.txt`） |
| 上游声明 | `setup.py: python_requires='>=3.9'`，classifiers 里 3.9/3.10/3.11/3.12/3.13/3.14 都列了 |
| 上游自身平台 | `classifiers` 里 `Operating System :: POSIX / MacOS :: MacOS X / Unix`——没写 Windows，Windows 腿不铺（不是偷懒，见下） |

不铺 Windows 的实测依据：`install_requires` 里有 `python-vagrant`、`apache-libcloud`、
`sdkmanager`、`clint` 这类 POSIX 取向的包，且上游 CI 全跑在 Debian 容器里
（`image: registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie`）。macOS 理论上可行
（classifiers 写了 MacOS X，且 setup.py 有 `biplist ; sys_platform=="darwin"` 这种平台条件），
如果后面要铺，得先有一条 CI 记录撑住，别先写结论。

## 版本钉法

`latest` = 从 `git ls-remote --tags` 里挑最新的纯数字 tag（当前解析到 2.4.5）；
固定分支 `python/fdroidserver_v/linux/2_4_5` 把 `FDROID_TAG` 写死。
脚本还会断言 `setup.py` 里的 `version=` 字面量等于本次 tag——上游是手写版本的
（`setup.py` 里 `version='2.4.5'`），这条断言能挡住"tag 抬了但 setup.py 忘了改"的错配。

## 三个坑（脚本注释里各有一份）

1. 上游只发 sdist。`python -m build` 的双产物万一失败，退回 `--sdist` 继续，判据落在
   "sdist 存在 + 能被 venv 装起来"，与上游 CI 一致。
2. `install_requires` 里有 `clint`、`oscrypto`、`ruamel.yaml<0.17.22`、`androguard`、
   `apache-libcloud` 这些有年头/有平台条件的包，新 Python 上不一定装得动。所以
   完整安装 + `fdroid version` 能跑通就是硬门槛；跑不通就 WARN，并把 pip 真正失败的环节
   打出来，同时退回 `--no-deps` 安装 + `import fdroidserver`，把"产物坏没坏"和
   "这台的依赖装不动"分开说清楚。
3. Ubuntu 24.04/26.04 的系统 Python 带 PEP 668 `EXTERNALLY-MANAGED`，直接 pip 会被拦，
   全程走 venv。

## 硬门槛

- `git describe --tags --exact-match HEAD` == 本次 tag；
- `setup.py` 的 `version=` == 本次 tag；
- `dist/fdroidserver-*.tar.gz` 存在，且 sdist 里有 `setup.py`、`pyproject.toml`、
  `fdroidserver/__main__.py`、`MANIFEST.in`；
- 出了 wheel 就再验：wheel 内含 `fdroidserver/__main__.py`，`entry_points.txt` 里有
  `fdroid` 这个 console_script；
- 依赖装得动时：`fdroid version` 输出必须包含本次 tag（这是"产物真能跑"的活证据）。

产物在 `_fdroid_build/artifacts/`（`fdroidserver-*.tar.gz`、`fdroidserver-*.whl`、
`python-build.log`、`BUILD_INFO.txt`、`sha256sums.txt`），workflow 上传成 `fdroidserver-<runner>`。
