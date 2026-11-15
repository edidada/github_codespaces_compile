# Xiaomi openvela — Linux / latest

This branch compiles Xiaomi's official openvela NuttX fork and its companion
application tree for NuttX's host `sim:nsh` configuration.

openvela is a very large multi-repository AIoT distribution.  The simulator
configuration provides a reproducible Linux-hosted compilation of its OS kernel
and app baseline without assuming an embedded board, proprietary SDK, or flash
device.  The resulting `nuttx` executable is the CI artifact checked here.

Sources: <https://github.com/open-vela/nuttx> and
<https://github.com/open-vela/nuttx-apps>
