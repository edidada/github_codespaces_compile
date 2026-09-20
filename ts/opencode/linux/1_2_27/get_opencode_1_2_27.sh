#! /bin/bash
sudo apt-get update
git --version
node -v
npm -v
git clone https://github.com/anomalyco/OpenCode.git
cd OpenCode
git checkout v1.2.27
npm install --registry=https://registry.npmmirror.com
npm install
npm run make
ls -la OpenCode/out/