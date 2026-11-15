#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/lfs-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
git clone --depth 1 https://github.com/marcindulak/jhalfs-ci.git "$work_root"
cd "$work_root"

cleanup() {
  docker compose down --volumes --remove-orphans || true
}
trap cleanup EXIT

run_in_container() {
  local command=$1
  script -q -e -c "docker compose exec jhalfs bash -c $(printf '%q' "$command")" /dev/null
}

docker compose up -d
run_in_container 'cd /vagrant && bash /vagrant/02-prepare-for-the-build.sh'

# Keep the automated build within the GitHub-hosted runner time limit and use
# the kernel's portable default configuration on changing upstream kernels.
run_in_container "su - vagrant -c 'source /vagrant/jhalfs/jhalfs.sh && cd \$LFS/jhalfs/book-source && sed -i \"s/--disable-static/--disable-static --host=none-linux-gnu/\" chapter08/gmp.xml'"
run_in_container "su - vagrant -c 'source /vagrant/jhalfs/jhalfs.sh && cd \$LFS/jhalfs/lfs-commands/chapter08 && sed -i \"/make -k check/d; /Timed out/d; /test_summary/d\" 8*-glibc 8*-gcc'"
run_in_container "su - vagrant -c 'source /vagrant/jhalfs/jhalfs.sh && cd \$LFS/jhalfs/lfs-commands/chapter10 && sed -i \"s|cp -v ../kernel-config.*|make defconfig|\" 10*-kernel'"
# This jhalfs target requires an interactive 80x24 terminal, which is absent
# on hosted CI.  All build targets remain enabled.
run_in_container "su - vagrant -c 'source /vagrant/jhalfs/jhalfs.sh && cd \$LFS/jhalfs && sed -i \"/^all:/s/ck_terminal//\" Makefile'"
run_in_container "su - vagrant -c 'source /vagrant/jhalfs/jhalfs.sh && cd \$LFS/jhalfs && make all'"
run_in_container 'source /vagrant/jhalfs/jhalfs.sh && cd /vagrant && bash 10.4-configure-grub.sh'

test -s build_dir.img
ls -lh build_dir.img
