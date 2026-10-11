# Cats functional-programming library

Builds the current [Typelevel Cats](https://github.com/typelevel/cats) source
with JDK 17 and sbt. Cats does not vendor an sbt launcher, so the script fetches
the standard `sbt-extras` launcher. It then compiles all project modules and
verifies that the `cats-core` artifact is emitted. Cats supplies the core Scala
functional-programming type classes, data types, syntax and laws.
