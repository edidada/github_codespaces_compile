# Scala compiler and standard library

Builds the upstream Scala repository from its latest default branch. The
repository does not vendor an sbt launcher, so the script obtains the standard
`sbt-extras` launcher and invokes upstream's `dist/mkPack` target. It checks
the generated `scalac` compiler and `scala-library.jar`, covering compiler,
standard library, reflection and distribution infrastructure rather than only
downloading a published artifact.
