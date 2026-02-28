#! /bin/bash
cd "$(dirname "$0")"
# 1. 下載最新 patch 版（以 1.24.13 為例，實際請去 https://go.dev/dl/ 確認最新版）
wget https://go.dev/dl/go1.22.12.linux-amd64.tar.gz

# 2. 刪除舊版（如果有）
sudo rm -rf /usr/local/go

# 3. 解壓到 /usr/local
sudo tar -C /usr/local -xzf go1.22.12.linux-amd64.tar.gz

# 4. 加入 PATH（建議加到 ~/.bashrc 或 ~/.zshrc）
cat << 'EOF' >> ~/.bashrc

export PATH=/usr/local/go/bin:$PATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF

# 立即生效
source ~/.bashrc

# 5. 驗證
go version
# 應該顯示類似：go version go1.24.13 linux/amd64

#!/usr/bin/env bash
set -euo pipefail

# ==================== 設定區 ====================
GO_VERSION="go1.24.13"           # 改成你想要的 tag 或分支
INSTALL_DIR="/usr/local/go"
BOOTSTRAP_VERSION="1.22.12"      # 1.24 需要 ≥1.22 來 bootstrap

echo "正在安裝 Go ${GO_VERSION} 從源碼..."

# 1. 安裝依賴
sudo apt update
sudo apt install -y git build-essential libgmp-dev libmpfr-dev libmpc-dev

# 2. 先準備一個 bootstrap Go（最簡單用官方二進制）
BOOTSTRAP_DIR="/tmp/go-bootstrap"
mkdir -p "$BOOTSTRAP_DIR"
cd "$BOOTSTRAP_DIR"

wget "https://go.dev/dl/go${BOOTSTRAP_VERSION}.linux-amd64.tar.gz"
tar -xzf "go${BOOTSTRAP_VERSION}.linux-amd64.tar.gz"

export GOROOT_BOOTSTRAP="${BOOTSTRAP_DIR}/go"

# 3. 下載 Go 源碼
mkdir -p ~/src/go
cd ~/src/go
git clone https://go.googlesource.com/go golang-go
cd golang-go

# 切換到想要的版本
git checkout "${GO_VERSION}" || git checkout "release-branch.${GO_VERSION%.*}"

# 4. 開始編譯（約 2–8 分鐘，看機器性能）
cd src
./make.bash -v

# 5. 安裝到系統目錄
sudo rm -rf "$INSTALL_DIR"
sudo mv "$(dirname "$PWD")" "$INSTALL_DIR"

# 6. 清理 bootstrap
rm -rf "$BOOTSTRAP_DIR"

# 7. 設定 PATH（同方法一）
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# 8. 驗證
go version
go env

echo "完成！Go ${GO_VERSION} 已安裝到 ${INSTALL_DIR}"