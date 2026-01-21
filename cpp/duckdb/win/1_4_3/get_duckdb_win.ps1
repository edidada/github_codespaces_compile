# 切换到脚本所在目录
Set-Location -Path $PSScriptRoot

# 克隆 duckdb 项目
git clone https://github.com/duckdb/duckdb.git
Set-Location -Path ./duckdb

# 切换到 v1.4.3 版本
git checkout v1.4.3

# 创建并进入构建目录
New-Item -ItemType Directory -Name build -Force | Out-Null
Set-Location -Path ./build

# 运行 CMake 配置
cmake ..
ninja