# Linux From Scratch — Linux / latest

This branch builds the current official **Linux From Scratch (LFS) book** from
its canonical `trunk` Git repository.

LFS is deliberately not a monolithic OS source tree: it is the reproducible
set of instructions for cross-toolchain bootstrap, kernel, C library and user
space construction.  A complete LFS installation requires a dedicated target
filesystem, elevated privileges and the book's sequential package builds, so
the CI job correctly validates and renders the book rather than claiming that
one hosted-runner invocation has produced a distributable Linux system.

`build.sh` installs the XML/XSLT toolchain required by the project, then runs
`make book nochunks`.  That validates the XML, generates the chunked and
single-page HTML books, and produces the associated download/checksum lists.

Source: <https://git.linuxfromscratch.org/lfs.git>
