# Ray on Linux

Ray is a Python-facing distributed computing runtime with native core services.
An editable source installation is used deliberately: it executes Ray's build
hooks and produces the checked-out native runtime rather than installing a
prebuilt package.  Linux is the supported CI target for that full native build.
