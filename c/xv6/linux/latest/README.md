# xv6-riscv — Linux / latest

This branch builds the current RISC-V edition of MIT PDOS xv6 from the official
`mit-pdos/xv6-riscv` repository and its `riscv` branch.

The earlier xv6-public x86 build script remains in the repository history, but
this CI entry uses the actively maintained RISC-V source tree.  It installs the
RISC-V bare-metal GCC/binutils toolchain and runs `make fs.img`, which produces
the kernel, user-space programs and xv6 file-system image.  QEMU is intentionally
not launched: the hosted runner validates the cross-compilation artifacts rather
than attempting an interactive emulator session.

Source: <https://github.com/mit-pdos/xv6-riscv>
