# Apache OpenDAL — Linux latest

- Foundation catalog: apache
- Source repository: https://github.com/apache/opendal.git
- Checkout ref: repository default branch
- Detected language: Rust
- Build policy: clone the requested revision and run the repository's native build and test system through `tools/foundations/build_project.sh`.

The branch and path follow `编程语言/软件名称/操作系统/版本`. A failing native build is kept visible in GitHub Actions and is repaired with project-specific prerequisites or commands rather than being reported as a pass.
OpenDAL is a multi-language umbrella repository. The primary Rust workspace is under `core/`; this target tests the core `opendal` library without optional storage services that require external native SDKs such as FoundationDB.
