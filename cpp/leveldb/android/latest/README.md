# LevelDB for Android

LevelDB is Google's C++ LSM-tree key-value store, widely used as the embedded
storage layer behind mobile caches and databases.  This branch uses the Android
NDK CMake toolchain to compile the production library for `arm64-v8a`.

Upstream unit tests are host executables, so the Android cross-build validates
the produced native library rather than attempting to execute target binaries
on the Linux runner.
