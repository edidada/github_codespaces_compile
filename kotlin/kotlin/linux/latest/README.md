# Kotlin compiler and standard library

Builds the current upstream Kotlin source distribution on Linux with JDK 17.
The `dist` Gradle task compiles the Kotlin compiler and standard library, then
assembles the `kotlinc` command-line distribution. The final checks verify the
compiler executable and `kotlin-stdlib.jar` produced from this checkout.
