#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

KONJOCOIND=${KONJOCOIND:-$BINDIR/litecoind}
KONJOCOINCLI=${KONJOCOINCLI:-$BINDIR/litecoin-cli}
KONJOCOINTX=${KONJOCOINTX:-$BINDIR/litecoin-tx}
WALLET_TOOL=${WALLET_TOOL:-$BINDIR/litecoin-wallet}
KONJOCOINQT=${KONJOCOINQT:-$BINDIR/qt/litecoin-qt}

[ ! -x $KONJOCOIND ] && echo "$KONJOCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BTCVER=($($KONJOCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for konjocoind if --version-string is not set,
# but has different outcomes for konjocoin-qt and konjocoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$KONJOCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $KONJOCOIND $KONJOCOINCLI $KONJOCOINTX $WALLET_TOOL $KONJOCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
