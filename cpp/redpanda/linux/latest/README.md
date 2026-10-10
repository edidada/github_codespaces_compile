# Redpanda Linux latest build

This branch builds the current Redpanda broker source on Linux. Redpanda's
official source instructions require its privileged dependency bootstrap and
Bazel release configuration; `//...` intentionally covers the complete
first-party build graph. macOS and Windows publish `rpk` client binaries, but
the Redpanda broker's supported source build is Linux-only.
