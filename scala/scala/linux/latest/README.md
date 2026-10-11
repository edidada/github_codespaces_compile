# Scala compiler and standard library

Builds the upstream Scala repository from its latest default branch. The
`dist` task bootstraps the `scalac` compiler and produces `scala-library.jar`,
covering the language compiler, standard library, reflection and distribution
infrastructure rather than only downloading a published artifact.
