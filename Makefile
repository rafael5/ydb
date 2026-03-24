# Makefile — YottaDB/MUMPS development workflow
# Mirrors the Python TDD workflow: make test / make watch / make push
#
# Requires: YottaDB installed, .envrc sourced (direnv allow)

SHELL := /bin/bash

YDB_DIST := $(shell ls -d /usr/local/lib/yottadb/r* 2>/dev/null | sort -V | tail -1)
YDB      := $(YDB_DIST)/ydb

# YottaDB environment
export ydb_dist   := $(YDB_DIST)
export ydb_dir    := $(HOME)/data/ydb
export ydb_gbldir := $(HOME)/data/ydb/g/ydb.gld
# ydb_routines: include munit only if installed; $(wildcard) returns "" if missing
export ydb_routines := $(strip \
    $(CURDIR)/routines \
    $(CURDIR)/routines/tests \
    $(wildcard $(CURDIR)/routines/munit) \
    $(YDB_DIST))

.PHONY: help test test-all watch install install-munit push check-env

help:
	@echo "YottaDB/MUMPS development targets:"
	@echo "  make install       Install YottaDB (needs sudo)"
	@echo "  make install-munit Install M-Unit testing framework"
	@echo "  make test          Run all test suites"
	@echo "  make watch         Re-run tests on file change (requires entr)"
	@echo "  make push          Commit and push to GitHub"
	@echo "  make check-env     Verify environment is correctly configured"

# ── Installation ─────────────────────────────────────────────────────────────

install:
	@echo "Installing YottaDB (requires sudo)..."
	sudo bash scripts/install-yottadb.sh
	@echo "Initializing database..."
	bash scripts/init-db.sh
	@echo "Done. Run: direnv allow && make test"

install-munit:
	bash scripts/install-munit.sh

# ── Testing ───────────────────────────────────────────────────────────────────

test: check-env
	@echo "==> Running HELLOTST..."
	@$(YDB) -run ^HELLOTST
	@echo "==> Running GLOBALTST..."
	@$(YDB) -run ^GLOBALTST
	@echo "==> Running GTREETST..."
	@$(YDB) -run ^GTREETST
	@echo "==> Running SAFETST..."
	@$(YDB) -run ^SAFETST
	@echo "==> Running TASKSTST..."
	@$(YDB) -run ^TASKSTST
	@echo "==> Running STRFNSTST..."
	@$(YDB) -run ^STRFNSTST
	@echo "==> Running CSVTST..."
	@$(YDB) -run ^CSVTST
	@echo ""
	@echo "All suites passed."

watch:
	@command -v entr >/dev/null 2>&1 || { echo "Install entr: sudo apt install entr"; exit 1; }
	find routines/ -name "*.m" | entr -c make test

# ── Git ───────────────────────────────────────────────────────────────────────

push:
	git push origin main

# ── Environment check ─────────────────────────────────────────────────────────

check-env:
	@if [[ -z "$(YDB_DIST)" ]]; then \
		echo "ERROR: YottaDB not found. Run: make install"; \
		exit 1; \
	fi
	@if [[ ! -f "$(HOME)/data/ydb/g/ydb.gld" ]]; then \
		echo "ERROR: Database not initialized. Run: bash scripts/init-db.sh"; \
		exit 1; \
	fi
