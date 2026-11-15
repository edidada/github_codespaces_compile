# rCore Tutorial v3 — Linux / latest

This branch cross-builds Tsinghua University's Rust-based teaching operating
system from the official `rcore-os/rCore-Tutorial-v3` repository.

The upstream `os/Makefile` installs the declared `riscv64gc-unknown-none-elf`
target and Rust binary utilities, then creates both the bare-metal kernel and
the user-space filesystem image with `make build`.  The target binaries cannot
run directly on the x86_64 GitHub runner, so the workflow verifies the emitted
RISC-V artifacts and does not invoke the interactive QEMU `make run` target.

Source: <https://github.com/rcore-os/rCore-Tutorial-v3>
