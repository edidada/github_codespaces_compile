# Seastar on Linux

Seastar is the C++ asynchronous runtime used by high-performance services such
as ScyllaDB and historically by Redpanda.  Its upstream dependency installer
and `configure.py` select the required compiler, networking and coroutine
settings, after which Ninja builds the release runtime.

This is a Linux build because Seastar's supported high-performance runtime and
dependency bootstrap target Linux.
