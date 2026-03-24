#!/usr/bin/env bash
# install-yottadb.sh — Install YottaDB using the official installer
# Run once with sudo. Safe to re-run.
#
# Usage: sudo bash scripts/install-yottadb.sh

set -euo pipefail

echo "==> Downloading official YottaDB installer..."
TMPFILE=$(mktemp /tmp/ydbinstall.XXXXXX.sh)
curl -fsSL https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh -o "$TMPFILE"

echo "==> Running installer (UTF-8 support enabled)..."
# --utf8 default: enables UTF-8 locale support (recommended)
# --overwrite-existing: safe for re-runs
bash "$TMPFILE" --utf8 default --force-install
rm -f "$TMPFILE"

echo "==> Finding installation path..."
YDB_DIST=$(ls -d /usr/local/lib/yottadb/r* 2>/dev/null | sort -V | tail -1)
if [[ -z "$YDB_DIST" ]]; then
    echo "ERROR: YottaDB installation not found in /usr/local/lib/yottadb/"
    exit 1
fi
echo "    Installed at: $YDB_DIST"

echo "==> Verifying installation..."
"$YDB_DIST/ydb" -run %XCMD 'write $ZYRELEASE,!'

echo ""
echo "SUCCESS: YottaDB installed."
echo ""
echo "Next step: run   bash scripts/init-db.sh   to create the database."
