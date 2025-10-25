#! /bin/bash
cd "$(dirname "$0")"

# 安装依赖
sudo apt update
sudo apt install -y \
    git build-essential meson ninja-build pkg-config \
    libcap-dev libmount-dev libblkid-dev libselinux-dev \
    libacl1-dev libapparmor-dev libaudit-dev libkmod-dev \
    libgcrypt20-dev liblz4-dev liblzma-dev libzstd-dev \
    libcurl4-gnutls-dev libmicrohttpd-dev libgnutls28-dev \
    libidn2-dev libpcre2-dev libcryptsetup-dev \
    libpwquality-dev libfdisk-dev libseccomp-dev \
    libpolkit-agent-1-0 libpolkit-gobject-1-dev \
    python3-pip python3-jinja2

# 下载代码
git clone https://github.com/systemd/systemd.git
cd systemd

# 切换到稳定版本 (这里以 v254 为例，您可以根据需要选择其他版本)
git checkout v254.10

# 配置编译选项
meson setup build \
    -Dmode=release \
    -Dsplit-usr=true \
    -Dsplit-bin=true \
    -Drootprefix=/usr \
    -Dselinux=true \
    -Dapparmor=true \
    -Dpolkit=true \
    -Dlibcurl=true \
    -Dgnutls=true \
    -Dmicrohttpd=true \
    -Dimportd=true \
    -Dhostnamed=true \
    -Dlocaled=true \
    -Dmachined=true \
    -Dportabled=true \
    -Dnetworkd=true \
    -Dresolve=true \
    -Dtimedated=true \
    -Dtimesyncd=true \
    -Dfirstboot=false \
    -Drandomseed=true \
    -Dbacklight=true \
    -Dvconsole=true \
    -Dquotacheck=true \
    -Dsysusers=true \
    -Dtmpfiles=true \
    -Dcoredump=true \
    -Dpstore=true \
    -Dlogind=true \
    -Dhwdb=true \
    -Drfkill=true \
    -Dman=true \
    -Dhtml=true

# 编译
cd build
ninja

# 安装 (可选，如果需要安装到系统)
sudo ninja install

BUILD_DIR="$(pwd)/build"

echo "=== 头文件 ==="
find $BUILD_DIR -name "*.h" -type f | head -10

echo -e "\n=== 库文件 ==="
find $BUILD_DIR -name "*.so*" -type f | head -10

echo -e "\n=== 可执行文件 ==="
find $BUILD_DIR -name "systemd" -o -name "systemctl" -o -name "journalctl" | head -10

echo -e "\n=== 绝对路径汇总 ==="
echo "头文件目录: $BUILD_DIR/src/libsystemd"
echo "库文件目录: $BUILD_DIR/src/libsystemd"
echo "可执行文件: $BUILD_DIR"