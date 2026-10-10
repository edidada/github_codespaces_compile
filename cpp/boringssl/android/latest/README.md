# BoringSSL for Android

BoringSSL is Google's TLS and cryptography library used by Chromium and Android
networking components.  This branch cross-compiles its SSL and crypto libraries
for Android `arm64-v8a` using the official NDK CMake toolchain.

The project test executables target Android and are not runnable on the hosted
Linux builder, so the cross-compiled library artifact is the validated output.
