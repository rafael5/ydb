#!/usr/bin/env bash
# install-munit.sh — Install M-Unit (%ut) testing framework for YottaDB
# M-Unit is the standard xUnit-style test framework for MUMPS/YottaDB.
# Run after YottaDB is installed.
#
# Usage: bash scripts/install-munit.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MUNIT_DIR="$PROJECT_DIR/routines/munit"

echo "==> Fetching M-Unit (OSEHRA) into routines/munit/ ..."
mkdir -p "$MUNIT_DIR"

# Clone the M-Unit repository (shallow, latest)
if [[ -d "$MUNIT_DIR/.git" ]]; then
    echo "    M-Unit already present. Pulling latest..."
    git -C "$MUNIT_DIR" pull --ff-only
else
    git clone --depth 1 https://github.com/OSEHRA/M-Unit.git "$MUNIT_DIR"
fi

echo ""
echo "==> M-Unit files:"
ls "$MUNIT_DIR"/*.m 2>/dev/null | xargs -I{} basename {}

echo ""
echo "SUCCESS: M-Unit installed at routines/munit/"
echo ""
echo "Your .envrc already includes routines/munit in ydb_routines."
echo "Run: direnv allow && make test"
