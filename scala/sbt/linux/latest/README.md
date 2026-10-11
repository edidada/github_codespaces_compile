# sbt build tool

Builds the current source of [sbt](https://github.com/sbt/sbt), the primary
Scala build tool. Its multi-module compile step builds the launcher and shell,
build-definition engine, incremental compilation integration and related
tooling. A generated sbt module class is required as the completion check; the
upstream development build writes compiled classes under `target/out`.
