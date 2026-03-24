#!/usr/bin/env bash
# init-db.sh — Initialize the YottaDB global directory and database
# Run once after install-yottadb.sh.
# Does NOT require sudo.
#
# Usage: bash scripts/init-db.sh

set -euo pipefail

# Find YottaDB distribution directory
YDB_DIST=$(ls -d /usr/local/lib/yottadb/r* 2>/dev/null | sort -V | tail -1)
if [[ -z "$YDB_DIST" ]]; then
    echo "ERROR: YottaDB not found. Run: sudo bash scripts/install-yottadb.sh"
    exit 1
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$HOME/data/ydb"
GLD="$DATA_DIR/g/ydb.gld"
DAT="$DATA_DIR/db/ydb.dat"

echo "==> Project:  $PROJECT_DIR"
echo "    Data dir: $DATA_DIR"
echo "    GLD:      $GLD"
echo "    Database: $DAT"
echo ""

# Source YottaDB env temporarily for this script
source "$YDB_DIST/ydb_env_set" 2>/dev/null || true

export ydb_dist="$YDB_DIST"
export ydb_dir="$DATA_DIR"
export ydb_gbldir="$GLD"
export ydb_routines="$PROJECT_DIR/routines $PROJECT_DIR/routines/tests $YDB_DIST"
export PATH="$YDB_DIST:$PATH"

echo "==> Creating global directory..."
cd "$DATA_DIR/g"
"$YDB_DIST/mumps" -run GDE << EOF
change -segment DEFAULT -file="$DAT"
change -region DEFAULT -dynamic=DEFAULT
exit
EOF

echo "==> Creating database..."
"$YDB_DIST/mupip" create

echo "==> Verifying..."
"$YDB_DIST/ydb" -run %xcmd 'set ^hello="world" write ^hello,! halt'

echo ""
echo "SUCCESS: Database initialized at $DAT"
echo ""
echo "Next: cd ~/projects/ydb && direnv allow"
echo "      Then: make test"
