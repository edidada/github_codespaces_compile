# Apache Teaclave — Linux latest

- Foundation catalog: apache
- Source repository: https://github.com/apache/teaclave-sgx-sdk.git
- Checkout ref: repository default branch
- Detected language: unspecified
- Build policy: clone the requested revision and run the repository's native build and test system through `tools/foundations/build_project.sh`.

The branch and path follow `编程语言/软件名称/操作系统/版本`. A failing native build is kept visible in GitHub Actions and is repaired with project-specific prerequisites or commands rather than being reported as a pass.
The current Teaclave repository is a landing page without buildable source. This target therefore builds the core `sgx_types` crate from the official Teaclave SGX SDK repository linked by that landing page.
