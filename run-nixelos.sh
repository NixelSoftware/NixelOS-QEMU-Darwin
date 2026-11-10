#!/bin/sh
# Boot NixelOS with the patched QEMU.
set -e

here=$(cd "$(dirname "$0")" && pwd)
qemu=$here/build-i386/qemu-system-nixel
os_dir=${NIXELOS_DIR:-$here/../NixelOS}

if [ ! -x "$qemu" ]; then
    echo "error: $qemu not built; run $here/build.sh first" >&2
    exit 1
fi

exec make -C "$os_dir" run QEMU="$qemu"
