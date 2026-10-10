# Redpanda 26.2.2 on Linux

This branch builds the Redpanda broker from the upstream `v26.2.2` source tag.
Redpanda is a Kafka-protocol-compatible streaming platform implemented in C++.

The upstream Linux dependency bootstrap is retained because the broker's Bazel
targets require system packages not included in a standard GitHub runner.  The
release build covers the complete broker target graph.  Redpanda's broker build
is Linux-focused, so this branch intentionally has no Windows or macOS variant.
