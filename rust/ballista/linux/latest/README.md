# Apache Arrow Ballista on Linux

Ballista is the distributed scheduler and executor layer built on Apache Arrow
DataFusion.  The script uses Cargo at workspace scope so it compiles both the
scheduler and executor crates, followed by their native Rust tests.

It is built on Linux because this repository's distributed-service runners are
Linux based; the upstream Rust workspace itself remains portable.
