#!/bin/bash
. $(dirname $0)/common.inc

echo 'int main() {}' | $GCC -flto -o /dev/null -xc - >& /dev/null \
  || skip

cat <<EOF | $GCC -flto -c -o $t/a.o -xc -
#include <stdio.h>
int main() {
  printf("Hello world\n");
}
EOF

$GCC -B. -o $t/exe -flto $t/a.o
$QEMU $t/exe | grep -q 'Hello world'

# Test that LTO is used for FAT LTO objects
cat <<EOF | $GCC -flto -ffat-lto-objects -c -o $t/a.o -xc -
#include <stdio.h>
int main() {
  printf("Hello world\n");
}
EOF
$GCC -B. -o $t/exe $t/a.o --verbose 2>&1 | grep -- -fwpa
