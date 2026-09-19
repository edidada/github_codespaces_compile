# Apache PouchDB — Linux 9_0_0

- Foundation catalog: apache
- Source repository: https://github.com/apache/pouchdb.git
- Checkout ref: 9.0.0
- Detected language: JavaScript
- Build policy: clone the requested revision and run the repository's native build and test system through `tools/foundations/build_project.sh`.

The branch and path follow `编程语言/软件名称/操作系统/版本`. A failing native build is kept visible in GitHub Actions and is repaired with project-specific prerequisites or commands rather than being reported as a pass.
This historical PouchDB codebase uses Node.js 18 because its legacy build plugins are not compatible with Node.js 22 on current GitHub-hosted runners. Its Node distribution is built before the Node-specific test suite runs.
