# MUMPS / YottaDB — Claude Context

## Environment
- YottaDB (GT.M-compatible MUMPS runtime), installed at `/usr/local/lib/yottadb/rXXX/`
- Database files: `~/data/ydb/` (not in git)
- Routines (source): `~/projects/ydb/routines/` (git-controlled)
- Direnv: `.envrc` sets all `ydb_*` env vars automatically on `cd`

## MUMPS Language Basics (for Claude)

### Syntax rules
- **Labels** start in column 1, no indentation
- **Code** is indented with one space (or tab) after the label
- **Comments** start with `;`
- **Newline in output**: `!` in a WRITE statement
- **String concatenation**: `_` operator  →  `"Hello, "_name_"!"`
- **No type system**: everything is a string; numeric context auto-converts
- **Variables are local by default**; globals start with `^`

### Key commands
```mumps
write "text",!          ; print with newline
set x=42                ; assignment
new x                   ; declare local variable (isolates from caller)
quit                    ; return from routine (no value)
quit value              ; return value from function
if cond  do label       ; conditional
for i=1:1:10  do label  ; loop
do label^routine        ; call a subroutine
$$func^routine(args)    ; call a function and get its return value
```

### Globals (persistent database storage)
```mumps
set ^MyGlobal("key")="value"    ; store
set x=^MyGlobal("key")          ; retrieve
kill ^MyGlobal("key")           ; delete
```

### Intrinsic functions (commonly used)
```mumps
$LENGTH(str)            ; string length
$PIECE(str,delim,n)     ; nth piece of delimited string
$EXTRACT(str,start,end) ; substring
$ZCONVERT(str,"U")      ; uppercase
$ZCONVERT(str,"L")      ; lowercase
$ORDER(^Global(key))    ; iterate global subscripts
$DATA(^Global(key))     ; check if node exists (0=no, 1=yes, 10=has children, 11=both)
```

### MUMPS routine file naming
- File name = routine name + `.m` extension
- Routine name = label at top of file
- Names are case-sensitive; convention is ALLCAPS for public routines, mixed for private

## Testing Setup

### Test runner (no external deps)
`routines/tests/TESTRUN.m` — lightweight runner that discovers `tXxx` labels.

Run a suite:
```bash
ydb -run ^TESTRUN HELLOTST
# or
make test
```

### M-Unit (%ut) — standard framework (install separately)
```bash
bash scripts/install-munit.sh    # clones OSEHRA/M-Unit into routines/munit/
```
Once installed, test routines can use `do assertEquals^%ut(actual,expected,"msg")`.

### TDD workflow
1. Create `routines/MYROUTINE.m` with stub functions
2. Create `routines/tests/MYROUTINETST.m` with `tXxx` tests
3. Add the suite to `make test` in Makefile
4. Run `make watch` for continuous test feedback

## Project Conventions
- Source: `routines/*.m` — application logic
- Tests:  `routines/tests/*TST.m` — naming convention: `ROUTINENAME` + `TST`
- Helpers: `routines/tests/TESTRUN.m` — test infrastructure (don't edit)
- Data paths:
  - Database: `~/data/ydb/db/ydb.dat`
  - Global directory: `~/data/ydb/g/ydb.gld`

## Running YottaDB interactively
```bash
ydb                         # interactive MUMPS prompt (GTM>)
ydb -run ^hello             # run routine directly
ydb -run ^TESTRUN HELLOTST  # run a test suite
```

At the `YDB>` prompt:
```mumps
do ^hello           ; run hello routine
write $$greet^hello("World"),!
halt                ; exit
```

## Code Style — "Lowercase Pythonic MUMPS"

Rafael's preferred style for this project. Less shouting, more readable.

### Labels
```mumps
; Public entry points — ALLCAPS (matches routine/file name convention)
MYROUTINE   ; public API

; Private sub-labels — lowercase (like Python functions)
show(gname)
walk(gname,depth,prefix)
mkref(gname,depth,curKey)
```

### No spaces in expressions
```mumps
; WRONG — parser stops at space around _
quit "Hello, "_ name _"!"

; RIGHT
quit "Hello, "_name_"!"
```

### Vertical spacing — blank comment lines between sections
```mumps
doSomething(x)
        new result
        set result=x+1
        ;
        if result>10 do handleBig(result)
        quit result
```

### if/else — use do blocks for clarity
```mumps
; prefer explicit do blocks over inline
if nextKey'="" do
.  set connector="├── "
.  set childPrefix=prefix_"│   "
else  do
.  set connector="└── "
.  set childPrefix=prefix_"    "
```

### Dynamic scoping — used intentionally
```mumps
; Variables new'd in a parent label are visible to called sub-labels.
; Document when you rely on this (e.g., path() in gtree.m).
show(gname)
        new path        ; inherited by walk() and mkref() below
        do walk(gname,1,"")
        quit
```

### $GET over direct read — avoid undefined variable errors
```mumps
; WRONG — errors if node doesn't exist
set x=^myGlobal("key")

; RIGHT
set x=$GET(^myGlobal("key"))          ; returns "" if missing
set x=$GET(^myGlobal("key"),"default") ; returns "default" if missing
```

### Naming
- Routines (filenames): `ALLCAPS.m` — e.g. `HELLOTST.m`, `GLOBALTST.m`
- Application routines: `lowercase.m` — e.g. `hello.m`, `gtree.m`, `globals.m`
- Test suites: `ROUTINENAMETST.m`
- Labels: lowercase for private, ALLCAPS only for public entry points

## Skills
- `~/claude/skills/mumps-language/` — MUMPS/M language reference (syntax, builtins, gotchas)
- `~/claude/skills/ydb-library/` — ydb project library and shell tool reference
