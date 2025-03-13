# 切换到脚本所在目录
Set-Location -Path $PSScriptRoot

# 使用 Chocolatey 安装必要的依赖（这里只是示例，部分依赖可能需要手动安装或通过其他方式获取）
choco install -y jsoncpp uuid zlib openssl c-ares brotli mariadb sqlite3 hiredis yaml-cpp gtest

# 克隆 Drogon 项目
git clone https://github.com/drogonframework/drogon
Set-Location -Path ./drogon

# 切换到 v1.9.3 版本
git checkout v1.9.3
git submodule update --init

# 创建并进入构建目录
New-Item -ItemType Directory -Name build -Force | Out-Null
Set-Location -Path ./build

# 运行 CMake 配置
cmake ..

# 编译并安装
msbuild ALL_BUILD.vcxproj /p:Configuration=Release /m:4
msbuild INSTALL.vcxproj /p:Configuration=Release

# 检查 drogon_ctl 版本
C:\Program Files\drogon\bin\drogon_ctl.exe version

# 返回上一级目录
Set-Location -Path ..

# 切换到 v1.9.9 版本
git checkout v1.9.9
git submodule update --init

# 删除并重新创建构建目录
Remove-Item -Path ./build -Recurse -Force
New-Item -ItemType Directory -Name build -Force | Out-Null
Set-Location -Path ./build

# 运行 CMake 配置
cmake ..

# 删除旧的 drogon_ctl
Remove-Item -Path "C:\Program Files\drogon\bin\drogon_ctl.exe" -Force

# 编译并安装
msbuild ALL_BUILD.vcxproj /p:Configuration=Release /m:4
msbuild INSTALL.vcxproj /p:Configuration=Release

# 检查 drogon_ctl 版本
C:\Program Files\drogon\bin\drogon_ctl.exe version