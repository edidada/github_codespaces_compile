# Apache log4php — Linux latest

- Foundation catalog: apache
- Source repository: http://svn.apache.org/repos/asf/logging/log4php/trunk
- Checkout ref: repository default branch
- Detected language: PHP
- Build policy: clone the requested revision and run the repository's native build and test system through `tools/foundations/build_project.sh`.

The branch and path follow `编程语言/软件名称/操作系统/版本`. A failing native build is kept visible in GitHub Actions and is repaired with project-specific prerequisites or commands rather than being reported as a pass.
The archived test suite uses the pre-namespaced PHPUnit API. It is run with its compatible PHPUnit 5 release in an isolated PHP 7.4 container rather than silently skipping tests on the current runner PHP.
