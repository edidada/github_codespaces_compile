# TensorFlow latest on linux

TensorFlow is a production machine-learning framework; this builds its official pip wheel target from C++ sources with CPU-only configuration.

The script performs a real source compilation with the upstream CMake, Python, or Bazel entry point. It follows the upstream default branch; tests are excluded so CI measures compilation rather than the full validation suite.
