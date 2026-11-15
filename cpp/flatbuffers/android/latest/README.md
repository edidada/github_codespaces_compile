# FlatBuffers for Android

FlatBuffers is Google's zero-copy serialization library used by games, mobile
applications and model runtimes.  This branch cross-compiles its C++ runtime
for Android `arm64-v8a` through the official NDK CMake toolchain.

The schema compiler and tests are host executables, so they are disabled for
the device-only cross-build; this workflow validates the native Android library.
