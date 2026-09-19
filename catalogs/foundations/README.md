# Foundation project build catalog

Generated from the canonical CNCF Landscape and Apache Projects directory.

## Scope

- CNCF active projects: 227
  - graduated: 39
  - incubating: 38
  - sandbox: 150
- Apache projects: 380
- Apache projects with an official stable release: 234

Archived CNCF entries are intentionally excluded. Apache entries follow the projects.apache.org directory exactly.

## Generated build coverage

- Apache Linux latest targets: 380/380 projects
- Apache Linux stable targets: 258 projects with a verified, non-prerelease Git tag
- Total Apache Linux workflows: 638

Projects without a verifiable stable source tag intentionally receive only a
`latest` target; an unrelated tag or an RC/beta tag is never labeled as the
industrial stable build. `coverage/apache-linux.json` maps every generated
branch to its repository, revision, source script, workflow, and validation
state. Generate it with `tools/foundations/generate_build_coverage.ps1`.

## Apache language summary

| Language | Projects |
| --- | ---: |
| Java | 267 |
| Python | 32 |
| C++ | 28 |
| C | 27 |
| JavaScript | 24 |
| Scala | 17 |
| C# | 14 |
| Go | 12 |
| Perl | 10 |
| Ruby | 9 |
| Rust | 7 |
| PHP | 6 |
| SQL | 5 |
| XML | 4 |
| Typescript | 3 |
| Node.js | 3 |
| Bash | 3 |
| Groovy | 3 |
| Objective-C | 2 |
| Tcl | 2 |
| R | 2 |
| ActionScript | 2 |
| JDBC | 2 |
| Erlang | 2 |
| C++,Java | 2 |
| OCaml | 1 |
| ODBC | 1 |
| Julia | 1 |
| Haxe | 1 |
| Freemarker | 1 |
| Delphi | 1 |
| Dart | 1 |
| Smalltalk | 1 |
| D | 1 |
| SVG | 1 |
| MATLAB | 1 |
| Lua | 1 |
| (unspecified) | 51 |

These catalogs are the source of truth for generated build branches and workflow coverage.
