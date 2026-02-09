#!/bin/bash
cd "$(dirname "$0")"
sudo apt update && sudo apt install -y openjdk-17-jdk maven git
echo "git clone idea_community"
git clone git://git.jetbrains.org/idea/community.git
cd community
git clone git://git.jetbrains.org/idea/android.git android
chmod +x getPlugins.sh installers.cmd
./getPlugins.sh
./installers.cmd -Dintellij.build.dev.mode=false -Dintellij.build.target.os=current
