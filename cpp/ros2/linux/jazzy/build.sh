#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/ros2-jazzy-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
mkdir -p "$work_root/src"

sudo apt-get update
sudo apt-get install -y python3-pip
sudo python3 -m pip install --break-system-packages --upgrade rosdep vcstool colcon-common-extensions
if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  sudo rosdep init
fi
rosdep update

git clone --depth=1 --branch jazzy https://github.com/ros2/ros2.git "$work_root/ros2"
vcs import "$work_root/src" < "$work_root/ros2/ros2.repos"
rosdep install --from-paths "$work_root/src" --ignore-src --rosdistro jazzy -y -r

cd "$work_root"
# rclcpp pulls in the supported ROS 2 client-library core without attempting
# hardware-dependent desktop demos on a hosted runner.
colcon build --merge-install --packages-up-to rclcpp
test -d install/rclcpp
