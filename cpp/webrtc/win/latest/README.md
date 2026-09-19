# WebRTC latest on win

This uses Google's supported depot_tools, fetch, gclient, GN, and Ninja flow and builds the native webrtc target. Tests and examples are disabled to bound CI compilation.

The script follows main when its required Windows SDK is installed. If WebRTC
main moves to a newer Visual Studio/SDK before the GitHub-hosted Windows image,
the script selects the newest fetched branch-head whose SDK is installed on the
runner. This keeps `latest` as new as the hosted toolchain can actually build
instead of failing on a nonexistent SDK include directory.
