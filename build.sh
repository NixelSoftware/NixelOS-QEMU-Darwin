#!/bin/sh
# Build the patched i386 QEMU.
#
# The macOS SDK bundled with the Command Line Tools may be newer than its own
# linker (its libSystem stub then contains an architecture ld does not know,
# which breaks even a hello-world link).  Probe the installed SDKs and export
# the first one that can compile and link.
set -e

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

printf 'int main(void){return 0;}\n' > "$tmp/probe.c"

if [ -z "$SDKROOT" ]; then
    for sdk in "$(xcrun --show-sdk-path 2>/dev/null)" \
               /Library/Developer/CommandLineTools/SDKs/MacOSX*.sdk; do
        [ -d "$sdk" ] || continue
        if cc -isysroot "$sdk" "$tmp/probe.c" -o "$tmp/probe" >/dev/null 2>&1; then
            SDKROOT=$sdk
            break
        fi
    done
    if [ -z "$SDKROOT" ]; then
        echo "error: no usable macOS SDK found" >&2
        exit 1
    fi
    export SDKROOT
fi

echo "Using SDKROOT=$SDKROOT"

mkdir -p "$here/build-i386"
cd "$here/build-i386"

if [ ! -f config-host.mak ]; then
    ../configure \
        --target-list=i386-softmmu \
        --enable-cocoa \
        --disable-docs \
        --disable-werror
fi

ninja qemu-system-nixel

echo
echo "Built: $here/build-i386/qemu-system-nixel"
