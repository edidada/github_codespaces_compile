# Li Auto HaloOS (星环 OS) — Linux / latest

This branch follows the official HaloOS VCOS manifest and builds the documented
`rt_demo` sample with the project's global `haloos_build.py` entry point.

HaloOS is a multi-repository automotive OS.  The build therefore uses Google's
`repo` client with Li Auto's public Gitee manifest (`vcos.xml`), instead of
pretending that one component repository represents the whole system.  The
official build configuration selects the freely available GCC toolchain for the
E3650 development-kit target; the CI validates its emitted `output` tree.

Sources: <https://gitee.com/haloos/manifests> and
<https://gitee.com/haloos/build>
