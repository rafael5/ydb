#!/usr/bin/env bash
# ydb-env.sh — Set up YottaDB environment variables.
# Source this from any script in bin/ or scripts/.
#
# Sets:  ydb_dist, ydb_dir, ydb_gbldir, ydb_routines, PATH
# Reads: PROJ_DIR (must be set by caller)

if [[ -z "${PROJ_DIR:-}" ]]; then
    echo "ydb-env.sh: PROJ_DIR not set" >&2
    exit 1
fi

YDB_DIST=$(ls -d /usr/local/lib/yottadb/r* 2>/dev/null | sort -V | tail -1)
if [[ -z "$YDB_DIST" ]]; then
    echo "Error: YottaDB not found. Run: sudo bash $PROJ_DIR/scripts/install-yottadb.sh" >&2
    exit 1
fi

export ydb_dist="$YDB_DIST"
export ydb_dir="$HOME/data/ydb"
export ydb_gbldir="$HOME/data/ydb/g/ydb.gld"

MUNIT_PATH=""
[[ -d "$PROJ_DIR/routines/munit" ]] && MUNIT_PATH=" $PROJ_DIR/routines/munit"
export ydb_routines="$PROJ_DIR/routines $PROJ_DIR/routines/tests${MUNIT_PATH} $YDB_DIST"

export PATH="$YDB_DIST:$PATH"
YDB="$YDB_DIST/ydb"
