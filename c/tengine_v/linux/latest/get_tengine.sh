#! /bin/bash
# Tengine 源码编译。分支名是 latest，所以取当前正式 release（3.1.0，2023-10-27 发布，
# 3.2.0 至今只有 rc 标签），内部基于 nginx 1.24.0。
#
# 2026-10-24（workflow 从已下线的 ubuntu-20.04 换成 ubuntu-latest 后，run 40056435654 失败）。
# 旧脚本三处都撑不到现在：
#
# (1) apt 那一行在 noble 上直接失败，实测（同 run 的完整日志）：
#       E: Package 'initscripts' has no installation candidate
#       E: Unable to locate package libgd2-xpm-dev
#       E: Unable to locate package libpcre0 / libpcre++-dev      （原文是 libpcre++0 / libpcre++-dev）
#     apt 只要有一个包装不上就整体退出，所以 libssl-dev / libpcre++-dev 一个都没装上，
#     后面 configure 才会说 “checking for PCRE library ... not found”。
#     注意：`libpcre++-dev` 是 PCRE 的 C++ wrapper，nginx 系列 configure 找的是 C 头 pcre.h
#     （在 libpcre3-dev 里），装错包了。
#
# (2) `--enable-mods-static=all` 在 tengine 3.1.0 的 auto/options 里已经不存在，
#     而 configure 遇到未知选项是 `error: invalid option`（auto/options:451），会直接终止。
#     `--with-ipv6` 只剩一句 deprecated 警告（auto/options:239），也一并去掉。
#
# (3) tengine-2.2.2（2016 年，基于 nginx 1.8.x）在 OpenSSL 3 下编不过，和 c/nginx_v 那边
#     放弃 1.8.1 是同一个原因，所以按分支语义升到 3.1.0。
set -euo pipefail
cd "$(dirname "$0")"

TENGINE_VERSION="3.1.0"
PREFIX="/usr/local/tengine"
WORK_DIR="$(pwd)/.work"
HTTP_PORT=18080
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/run"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
# PCRE2 + PCRE1 都装：tengine 3.1.0（nginx 1.24 系）优先探测 PCRE2，这里让它探到什么都编得过
sudo apt-get install -y -qq build-essential git zlib1g-dev libpcre2-dev libpcre3-dev \
    libssl-dev libxslt1-dev libxml2-dev perl

echo "==== 2. 取源码 ===="
rm -rf tengine
git clone -q --depth 1 -b "$TENGINE_VERSION" https://github.com/alibaba/tengine.git tengine
cd tengine
./configure --enable-mods-static=all --with-ipv6 --with-http_v2_module
make -j2
sudo make install
