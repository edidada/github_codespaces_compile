#!/bin/bash
# PostgreSQL 19 构建脚本
set -e  # 如果任何命令失败则退出

cd "$(dirname "$0")"

echo "====================================="
echo "开始构建 PostgreSQL 19"
echo "====================================="

# 1. 安装编译依赖
echo "1. 安装系统依赖..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y build-essential \
            gcc g++ make \
            libreadline-dev \
            zlib1g-dev \
            flex bison \
            libssl-dev \
            libxml2-dev \
            libxslt-dev \
            libpam0g-dev \
            libperl-dev \
            libicu-dev \
            libzstd-dev \
            pkg-config \
            python3 \
            curl
    # RHEL/CentOS/Fedora
    elif command -v yum &> /dev/null; then
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y readline-devel \
            zlib-devel \
            flex bison \
            openssl-devel \
            libxml2-devel \
            libxslt-devel \
            pam-devel \
            perl-devel \
            perl-ExtUtils-Embed \
            libicu-devel \
            libzstd-devel \
            python3
    elif command -v dnf &> /dev/null; then
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y readline-devel \
            zlib-devel \
            flex bison \
            openssl-devel \
            libxml2-devel \
            libxslt-devel \
            pam-devel \
            perl-devel \
            perl-ExtUtils-Embed \
            libicu-devel \
            libzstd-devel \
            python3
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo "错误: 需要 Homebrew。请先安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    brew install \
        gcc \
        make \
        readline \
        zlib \
        openssl \
        libxml2 \
        libxslt \
        icu4c \
        zstd \
        python@3.12
else
    echo "不支持的操作系统: $OSTYPE"
    exit 1
fi

# 2. 下载 PostgreSQL 19
echo "2. 下载 PostgreSQL 19..."
POSTGRES_VERSION="19.6"
POSTGRES_URL="https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.bz2"

# 下载 PostgreSQL
if [[ ! -f "postgresql-${POSTGRES_VERSION}.tar.bz2" ]]; then
    echo "正在下载 PostgreSQL ${POSTGRES_VERSION}..."
    curl -L -O "$POSTGRES_URL" || wget "$POSTGRES_URL"
fi

# 3. 解压
echo "3. 解压 PostgreSQL..."
if [[ ! -d "postgresql-${POSTGRES_VERSION}" ]]; then
    tar -xjf "postgresql-${POSTPOSTGRES_VERSION}.tar.bz2"
fi

cd "postgresql-${POSTGRES_VERSION}"

# 4. 配置构建目录
echo "4. 准备构建目录..."
rm -rf build
mkdir -p build && cd build

# 5. 设置环境变量
echo "5. 设置构建环境..."
    ../configure \
        --prefix=/usr/local/pgsql-19 \
        --with-openssl \
        --with-libxml \
        --with-libxslt \
        --with-pam \
        --with-perl \
        --with-python \
        --with-icu \
        --with-zstd \
        --enable-debug \
        --enable-dtrace \
        --with-uuid=e2fs \
        CC="gcc" \
        CXX="g++" \
        CFLAGS="-O2 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv"
fi

# 6. 编译
echo "6. 编译 PostgreSQL 19..."
CPU_COUNT=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
echo "使用 $CPU_COUNT 个CPU核心进行编译..."
make -j$(($CPU_COUNT + 1))

# 7. 安装
echo "7. 安装 PostgreSQL 19..."
sudo make install
