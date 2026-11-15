# libsodium for Android

libsodium is a portable C cryptography library used by mobile applications for
modern authenticated encryption, signatures and key exchange.  This branch
cross-compiles its static native library for Android `arm64-v8a` with the NDK
API-24 toolchain.

Target test binaries are not executable on the Linux hosted runner, so the
Android artifact build is validated instead of running host-incompatible tests.
