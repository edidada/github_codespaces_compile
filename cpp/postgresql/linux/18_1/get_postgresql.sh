#!/bin/bash
set -e  # 如果任何命令失败则退出
cd "$(dirname "$0")"
sudo apt update
sudo apt-get install -y \
    meson \
    flex \
    libavahi-compat-libdnssd-dev \
    avahi-daemon \
    avahi-utils \
    libkrb5-dev \
    libldap2-dev \
    libpam0g-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    xsltproc \
    libsystemd-dev \
    pkg-config \
    systemd \
    python3.12-dev \
    python3.12-venv \
    libpython3.12 \
    libselinux1-dev \
    selinux-utils \
    policycoreutils \
    perl \
    libipc-run-perl \
    libtest-simple-perl \
    libtap-parser-sourcehandler-pgtap-perl \
    gettext \
    gettext-base \
    libgettextpo-dev
git clone https://github.com/postgres/postgres.git postgresql-dev
cd postgresql-dev
git checkout REL_18_STABLE
mkdir build && cd build
meson setup .. \
    --prefix=/usr/local/pgsql-18 \
    --buildtype=debugoptimized \
    -Doptimization=2 \
    -Db_ndebug=true \
    -Dc_args="-Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv" \
    -Dpam=enabled \
    -Dldap=enabled \
    -Dbonjour=enabled \
    -Dgssapi=enabled \
    -Dselinux=enabled \
    -Dsystemd=enabled \
    -Dicu=enabled \
    -Dtap_tests=enabled \
    -Dnls=enabled
CPU_COUNT=$(nproc 2>/dev/null || echo 4)
ninja -j$CPU_COUNT
