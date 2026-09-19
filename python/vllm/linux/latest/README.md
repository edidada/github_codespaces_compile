# vLLM latest on linux

vLLM is a high-throughput LLM serving and inference engine; CPU mode exercises its native extension build without requiring a GPU runner.

The script performs a real source compilation with the upstream CMake, Python, or Bazel entry point. It follows the upstream default branch; tests are excluded so CI measures compilation rather than the full validation suite.
