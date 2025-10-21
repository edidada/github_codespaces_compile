#!/bin/bash
cd "$(dirname "$0")"
echo "git clone idea_community"
git clone git://git.jetbrains.org/idea/community.git --depth 1
cd community
git clone git://git.jetbrains.org/idea/android.git android --depth 1
chmod +x getPlugins.sh
./getPlugins.sh
./installers.cmd -Dintellij.build.dev.mode=false -Dintellij.build.target.os=current