#!/usr/bin/env bash
set -euo pipefail

: "${PROJECT_NAME:?PROJECT_NAME is required}"
: "${PROJECT_REPOSITORY:?PROJECT_REPOSITORY is required}"
: "${PROJECT_VERSION:=latest}"
: "${PROJECT_REF:=}"

export CI=true
export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-2}"
export CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-2}"
export MAKEFLAGS="${MAKEFLAGS:--j2}"

work_root="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/foundation-${GITHUB_RUN_ID:-local}-${GITHUB_RUN_ATTEMPT:-1}"
rm -rf -- "$work_root"
mkdir -p -- "$work_root"

echo "Project: $PROJECT_NAME"
echo "Repository: $PROJECT_REPOSITORY"
echo "Requested version: $PROJECT_VERSION"

if [[ "$PROJECT_REPOSITORY" == *svn.apache.org* ]]; then
  command -v svn >/dev/null || { sudo apt-get update; sudo apt-get install -y subversion; }
  svn checkout --non-interactive "$PROJECT_REPOSITORY" "$work_root/source"
else
  clone_args=(--filter=blob:none --depth=1)
  if [[ -n "$PROJECT_REF" && "$PROJECT_VERSION" != latest ]]; then
    clone_args+=(--branch "$PROJECT_REF")
  fi
  if ! git clone "${clone_args[@]}" "$PROJECT_REPOSITORY" "$work_root/source"; then
    echo "Shallow clone of ref '$PROJECT_REF' failed; retrying with tag/branch discovery."
    rm -rf -- "$work_root/source"
    git clone --filter=blob:none "$PROJECT_REPOSITORY" "$work_root/source"
    if [[ -n "$PROJECT_REF" && "$PROJECT_VERSION" != latest ]]; then
      git -C "$work_root/source" checkout "$PROJECT_REF"
    fi
  fi
fi

cd "$work_root/source"
git rev-parse HEAD 2>/dev/null || true

# Some foundation repositories are umbrellas whose actual build root is one
# or two directories below the checkout root (for example OpenDAL's `core/`).
# Prefer a root build descriptor, then select the shallowest descriptor using
# a deterministic build-system priority.
root_descriptor_found=false
for descriptor in pom.xml build.gradle build.gradle.kts gradlew build.xml go.mod Cargo.toml mix.exs rebar.config rebar.config.script package.json pyproject.toml setup.py setup.cfg CMakeLists.txt configure configure.ac autogen.sh WORKSPACE WORKSPACE.bazel MODULE.bazel Gemfile Rakefile composer.json Makefile makefile GNUmakefile; do
  if [[ -e "$descriptor" ]]; then
    root_descriptor_found=true
    break
  fi
done
if [[ "$root_descriptor_found" == false ]]; then
  for descriptor in pom.xml build.gradle build.gradle.kts build.xml go.mod Cargo.toml mix.exs rebar.config package.json pyproject.toml setup.py CMakeLists.txt configure configure.ac WORKSPACE WORKSPACE.bazel MODULE.bazel Gemfile composer.json Makefile; do
    nested_descriptor="$(find . -mindepth 2 -maxdepth 4 -type f -name "$descriptor" -not -path '*/.git/*' -not -path '*/node_modules/*' -print -quit)"
    if [[ -n "$nested_descriptor" ]]; then
      cd "$(dirname "$nested_descriptor")"
      echo "Selected nested build root: $PWD ($descriptor)"
      break
    fi
  done
fi

run_maven() {
  local mvn_cmd=(mvn)
  [[ -x ./mvnw ]] && mvn_cmd=(./mvnw)
  "${mvn_cmd[@]}" -B -ntp -DskipITs test
}

run_gradle() {
  local gradle_cmd=(gradle)
  [[ -x ./gradlew ]] && gradle_cmd=(./gradlew)
  "${gradle_cmd[@]}" --no-daemon test
}

run_node() {
  if [[ -f pnpm-lock.yaml ]]; then
    corepack enable
    pnpm install --frozen-lockfile
    pnpm test
  elif [[ -f yarn.lock ]]; then
    corepack enable
    yarn install --immutable || yarn install --frozen-lockfile
    yarn test
  else
    if [[ -f package-lock.json || -f npm-shrinkwrap.json ]]; then npm ci; else npm install; fi
    npm test
  fi
}

run_python() {
  python -m pip install --upgrade pip build pytest tox
  if [[ -f requirements.txt ]]; then python -m pip install -r requirements.txt; fi
  python -m pip install -e '.[test]' || python -m pip install -e .
  if [[ -d tests || -f pytest.ini || -f tox.ini ]]; then
    python -m pytest
  else
    python -m build
  fi
}

if [[ -f pom.xml ]]; then
  run_maven
elif [[ -f build.gradle || -f build.gradle.kts || -f gradlew ]]; then
  run_gradle
elif [[ -f build.xml ]]; then
  ant test || ant
elif [[ -f go.mod ]]; then
  if [[ -f Makefile ]] && make -qp 2>/dev/null | grep -Eq '^test:'; then
    make test
  else
    go test ./...
  fi
elif [[ -f Cargo.toml ]]; then
  cargo test --workspace --all-targets
elif [[ -f mix.exs ]]; then
  mix local.hex --force
  mix local.rebar --force
  mix deps.get
  mix test
elif [[ -f rebar.config || -f rebar.config.script ]]; then
  if [[ -x ./rebar3 ]]; then ./rebar3 eunit; else rebar3 eunit; fi
elif [[ -f package.json ]]; then
  run_node
elif [[ -f pyproject.toml || -f setup.py || -f setup.cfg ]]; then
  run_python
elif compgen -G '*.sln' >/dev/null || compgen -G '*.csproj' >/dev/null; then
  dotnet test
elif [[ -f configure || -f configure.ac || -f autogen.sh || -f buildconf ]]; then
  [[ -x ./buildconf ]] && ./buildconf
  [[ -x ./autogen.sh ]] && ./autogen.sh
  [[ -x ./configure ]] || autoreconf -fi
  ./configure
  make
  make check
elif [[ -f CMakeLists.txt ]]; then
  cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
  cmake --build build --parallel 2
  ctest --test-dir build --output-on-failure
elif [[ -f WORKSPACE || -f WORKSPACE.bazel || -f MODULE.bazel ]]; then
  if command -v bazelisk >/dev/null; then bazelisk test //...; else npx --yes @bazel/bazelisk test //...; fi
elif [[ -f Gemfile || -f Rakefile ]]; then
  bundle install
  bundle exec rake test || bundle exec rake
elif [[ -f composer.json ]]; then
  composer install --no-interaction
  composer test || vendor/bin/phpunit
elif [[ -f Makefile || -f makefile || -f GNUmakefile ]]; then
  make
  if make -qp 2>/dev/null | grep -Eq '^test:'; then make test; fi
else
  echo "No supported build system was detected in $PROJECT_NAME." >&2
  find . -maxdepth 2 -type f | sort | head -200 >&2
  exit 2
fi
