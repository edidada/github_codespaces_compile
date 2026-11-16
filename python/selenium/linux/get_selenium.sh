#! /usr/bin/env bash
#
# Selenium 4.15.0 Python 绑定（selenium/py）源码编译：
# 仓库根目录没有 pom.xml（Java 侧走 Bazel），Python 绑定在 py/ 子目录
# 用 poetry-core 打包。pip install -e . + import 验证。
set -euo pipefail
cd "$(dirname "$0")"
rm -rf selenium
git clone --quiet --depth=1 -b selenium-4.15.0 https://github.com/seleniumhq/selenium.git
cd selenium/py
python3 -m pip install --quiet --upgrade pip build
python3 -m pip install --quiet -e .
python3 -c "import selenium; print('PASS selenium', selenium.__version__)"
echo "PASS: selenium python bindings 构建完成"
