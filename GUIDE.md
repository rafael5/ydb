# Beginner's Guide to YottaDB / MUMPS

This guide walks you through the routines, utilities, and test infrastructure in this
project. It assumes no prior MUMPS experience but does assume basic programming
knowledge (variables, loops, functions).

---

## Table of Contents

1. [Environment setup](#1-environment-setup)
2. [MUMPS syntax crash course](#2-mumps-syntax-crash-course)
3. [Your first routine — `hello.m`](#3-your-first-routine--hellom)
4. [Globals — the YottaDB database (`globals.m`)](#4-globals--the-yottadb-database-globalsm)
5. [Visualizing globals — `gtree.m`](#5-visualizing-globals--gtreem)
6. [String utilities — `strfns.m`](#6-string-utilities--strfnsm)
7. [Error handling — `safe.m`](#7-error-handling--safem)
8. [CSV import — `csv.m`](#8-csv-import--csvm)
9. [Persistent task manager — `tasks.m`](#9-persistent-task-manager--tasksm)
10. [Writing and running tests](#10-writing-and-running-tests)

---

## 1. Environment setup

### Install YottaDB and initialize the database

```bash
make install          # installs YottaDB (needs sudo) and creates ~/data/ydb/
```

### Verify everything is working

```bash
make check-env        # confirms YottaDB is found and the database exists
make test             # runs all test suites; all should pass
```

### Directory layout

```
routines/             # application code — the .m files you read and write
routines/tests/       # test suites — one per routine, named ROUTINAMETST.m
scripts/              # install helpers and ydb-env.sh
Makefile              # test / lint / watch / push targets
~/data/ydb/           # database files (not in git)
```

### Interactive MUMPS prompt

```bash
ydb                   # opens the YDB> prompt
```

Inside the prompt:

```mumps
YDB> write "hello",!
hello
YDB> halt
```

### Run a routine directly

```bash
ydb -run ^hello       # runs the default entry point of hello.m
ydb -run ^HELLOTST    # runs the hello test suite
```

---

## 2. MUMPS syntax crash course

### The basics

```mumps
; Comment — semicolons start a comment anywhere on a line
write "Hello",!          ; print with a newline (! = newline in WRITE)
set x=42                 ; assignment
new x                    ; declare a local variable (scoped to this call frame)
kill x                   ; delete a variable
quit                     ; return from a subroutine
quit value               ; return a value from a function
```

### Labels and indentation

Labels **must** start in column 1. Code is indented with one space (or a tab).
A file's name is its routine name.

```mumps
myRoutine       ; label at column 1 — also the routine's entry point
        write "hi",!
        quit
        ;
helper(x)       ; sub-label with a parameter
        quit x+1
```

### Calling code

```mumps
do label^routine          ; call a subroutine (no return value)
set y=$$func^routine(x)   ; call a function and capture its return value
```

The `$$` prefix tells MUMPS you want the return value. Without it the call is
a subroutine call and the return value is discarded.

### String concatenation

```mumps
; Use _ (underscore) — NO spaces around it or the parser breaks
set msg="Hello, "_name_"!"
```

### Conditionals and loops

```mumps
if x>0 write "positive",!

; For loop: start : step : end
for i=1:1:10  write i,!

; Open-ended loop — quit when condition is met
for  set key=$order(^myGlobal(key)) quit:key=""  do
.  write key,!
```

### Type system (there isn't one)

Everything is a string. Numeric context converts automatically.

```mumps
set x="42"
write x+1,!     ; prints 43
```

### Case sensitivity

Built-in keywords are **case-insensitive**. User-defined names are **case-sensitive**.

| Category | Case-sensitive? | Examples |
|----------|----------------|---------|
| Commands | No | `set`, `SET`, `Set` — all identical |
| Intrinsic functions | No | `$get`, `$GET`, `$Get` — all identical |
| Special variables | No | `$etrap`, `$ETRAP` — identical |
| User variables | **Yes** | `myVar` ≠ `myvar` |
| Labels / routine names | **Yes** | `hello` ≠ `Hello` |
| Global names | **Yes** | `^tasks` ≠ `^Tasks` |

So `$get`, `$order`, `$data`, `for`, `kill` are all valid lowercase spellings.
The uppercase convention you'll see in most MUMPS code online — and throughout
this guide — is stylistic, not required. It visually separates built-ins from
user code but either style works.

This project uses a "Lowercase Pythonic MUMPS" style for user-defined labels and
prefers lowercase built-ins in application code (e.g. `$get` in `safe.m`),
though test files and older routines use uppercase. Pick one and be consistent
within a file.

---

## 3. Your first routine — `hello.m`

[routines/hello.m](routines/hello.m) contains three entry points:

| Label | Signature | What it does |
|-------|-----------|--------------|
| `hello` | (default) | Prints "Hello, World!" |
| `greet` | `greet(name)` | Returns `"Hello, <name>!"` |
| `shout` | `shout(name)` | Returns `"HELLO, <NAME>!"` using `$ZCONVERT` |

### Try it interactively

```bash
ydb
```

```mumps
YDB> do ^hello
Hello, World!

YDB> write $$greet^hello("Alice"),!
Hello, Alice!

YDB> write $$shout^hello("alice"),!
HELLO, ALICE!

YDB> halt
```

### Key concepts demonstrated

- **Default entry point**: `do ^routineName` runs the first label in the file.
- **Function call syntax**: `$$label^routine(args)` — the `$$` captures the return value.
- **String concatenation**: `"Hello, "_name_"!"` — no spaces around `_`.
- **`$ZCONVERT(str,"U")`** — YottaDB extension to uppercase a string.

---

## 4. Globals — the YottaDB database (`globals.m`)

[routines/globals.m](routines/globals.m) introduces YottaDB's persistent storage.

Globals are hierarchical key-value stores. They live in the `.dat` database file
and survive process restarts. Names start with `^`.

### Basic storage

```mumps
YDB> set ^demo("color")="blue"         ; store
YDB> write ^demo("color"),!            ; retrieve → blue
YDB> kill ^demo("color")               ; delete one node
YDB> kill ^demo                        ; delete the entire global
```

Using the wrappers in `globals.m`:

```mumps
YDB> do basicSet^globals("color","blue")
YDB> write $$basicGet^globals("color"),!
blue
YDB> do basicDel^globals("color")
YDB> write $$basicGet^globals("color"),!
                                        ; empty string — safe, no crash
```

### Always use `$GET` for reads

Reading a non-existent node throws an error in raw MUMPS. Use `$GET`:

```mumps
; WRONG — crashes if node doesn't exist
set x=^demo("missing")

; RIGHT — returns "" (or a default) if missing
set x=$get(^demo("missing"))
set x=$get(^demo("missing"),"unknown")
```

`basicGet^globals` does this for you.

### Multi-level subscripts (nested keys)

Globals are trees. You can nest subscripts to any depth:

```mumps
YDB> do storeContact^globals("Alice","phone","555-1234")
YDB> do storeContact^globals("Alice","email","alice@example.com")
YDB> do storeContact^globals("Bob","phone","555-9999")
YDB> write $$getContact^globals("Alice","phone"),!
555-1234
```

Under the hood this stores: `^contacts("Alice","phone")="555-1234"`

### Iterating with `$ORDER`

`$ORDER` is the MUMPS iterator. It returns the next subscript in collation order.
Pass `""` to get the first key; it returns `""` when exhausted.

```mumps
YDB> write $$listKeys^globals(),!
apple,banana,cherry
```

The implementation:

```mumps
listKeys()
        new result,key
        set result="",key=""
        for  set key=$ORDER(^demo(key)) quit:key=""  do
        . if result'="" set result=result_","
        . set result=result_key
        quit result
```

### Checking existence with `$DATA`

`$DATA` returns:
- `0` — node doesn't exist
- `1` — has a value but no children
- `10` — has children but no value
- `11` — has both a value and children

```mumps
YDB> write $$exists^globals("color"),!        ; 1 if set, 0 if not
YDB> write $$hasChildren^globals("user"),!    ; 1 if has child nodes
```

---

## 5. Visualizing globals — `gtree.m`

[routines/gtree.m](routines/gtree.m) prints any global as a tree, like the Unix
`tree` command.

```bash
YDB> do show^gtree("contacts")
```

Output:

```
^contacts
├── Alice
│   ├── city: Portland
│   ├── email: alice@example.com
│   └── phone: 555-1234
└── Bob
    └── phone: 555-9999
```

You can pass the name with or without the leading `^`:

```mumps
do show^gtree("contacts")
do show^gtree("^contacts")    ; leading ^ is stripped automatically
```

`gtree` is also wired into `tasks.m` — `do show^tasks()` dumps the raw
`^tasks` global as a tree for debugging.

### How it works (brief)

The private `mkref` function builds a YottaDB reference string dynamically:

```mumps
mkref("contacts", 1, "Alice")       →  ^contacts("Alice")
mkref("contacts", 2, "phone")       →  ^contacts("Alice","phone")
```

`walk` recursively iterates subscripts at each level, choosing `├──` or `└──`
depending on whether the current node is the last sibling.

---

## 6. String utilities — `strfns.m`

[routines/strfns.m](routines/strfns.m) wraps MUMPS built-in string functions with
readable names. All are called as `$$fn^strfns(...)`.

### Decomposition

| Function | Example | Result |
|----------|---------|--------|
| `piece(str,delim,n)` | `$$piece^strfns("a,b,c",",",2)` | `"b"` |
| `count(str,delim)` | `$$count^strfns("a,b,c",",")` | `3` |
| `sub(str,from,to)` | `$$sub^strfns("hello",2,4)` | `"ell"` |
| `left(str,n)` | `$$left^strfns("hello",3)` | `"hel"` |
| `right(str,n)` | `$$right^strfns("hello",3)` | `"llo"` |

> **Note:** All positions are 1-based and inclusive, like MUMPS `$EXTRACT`.

### Search

| Function | Example | Result |
|----------|---------|--------|
| `find(str,target)` | `$$find^strfns("hello world","world")` | `7` |
| `contains(str,target)` | `$$contains^strfns("hello","ell")` | `1` |
| `startsWith(str,prefix)` | `$$startsWith^strfns("hello","hel")` | `1` |
| `endsWith(str,suffix)` | `$$endsWith^strfns("hello","llo")` | `1` |

> **Gotcha:** The raw `$FIND` built-in returns the position *after* the match,
> not the start. The `find` wrapper corrects this to return the start position,
> which is more intuitive.

### Transformation

| Function | Example | Result |
|----------|---------|--------|
| `upper(str)` | `$$upper^strfns("hello")` | `"HELLO"` |
| `lower(str)` | `$$lower^strfns("HELLO")` | `"hello"` |
| `trim(str)` | `$$trim^strfns("  hi  ")` | `"hi"` |
| `replace(str,from,to)` | `$$replace^strfns("hello","l","L")` | `"heLLo"` |
| `translate(str,from,to)` | `$$translate^strfns("hello","aeiou","AEIOU")` | `"hEllO"` |
| `pad(str,width)` | `$$pad^strfns("hi",6)` | `"hi    "` |

`replace` substitutes a multi-character string with another. `translate` works
character-by-character (like bash `tr`). `pad` right-pads to a fixed width —
useful for aligned table output.

---

## 7. Error handling — `safe.m`

[routines/safe.m](routines/safe.m) teaches MUMPS error handling and provides
reusable patterns.

### MUMPS error handling vocabulary

| Variable | Meaning |
|----------|---------|
| `$ETRAP` | Code string executed on error. `new $ETRAP` scopes it to the current call frame. |
| `$ECODE` | Active error code (e.g. `",M9,"`). Set to `""` to clear. |
| `$ZSTATUS` | Human-readable error string from YottaDB. |
| `$QUIT` | `1` if current context expects a return value, `0` if subroutine. |

### Safe division

```mumps
write $$divide^safe(10,2),!    ; → 5
write $$divide^safe(10,0),!    ; → ""  (instead of crashing)
```

### Precondition checks — `require`

`require^safe(condition, message)` raises a user error (U1) if the condition is
false. Think of it as MUMPS's equivalent of `assert` or `raise ValueError`.

```mumps
do require^safe(age>0, "age must be positive")
do require^safe(name'="", "name is required")
```

If the condition fails, `$ECODE` is set to `",U1,"` and the message is stored in
`^lastError`. The caller's `$ETRAP` fires just like any other error.

Retrieve the last error message:

```mumps
write $$lastError^safe(),!
```

### Try/catch — `tryCatch`

```mumps
new ok, errMsg
do tryCatch^safe("set x=1/0", .ok, .errMsg)
if 'ok write "caught: ", errMsg, !
```

`tryCatch` executes an arbitrary string of MUMPS code. If it succeeds, `ok=1`.
If it errors, `ok=0` and `errMsg` is set to `$ZSTATUS`.

The `.ok` and `.errMsg` syntax passes variables **by reference** (the dot prefix
is the MUMPS pass-by-reference convention). Changes inside `tryCatch` are
reflected in the caller's variables.

### The try/catch pattern from scratch

You can also write this inline without `tryCatch`:

```mumps
new $ETRAP, ok, errMsg
set ok=1, errMsg=""
set $ETRAP="set ok=0,errMsg=$zstatus set $ECODE="""""
; ... code that might fail ...
if 'ok do handleError(errMsg)
```

`new $ETRAP` ensures the handler is restored when this call frame exits — it
won't interfere with the caller's error handler.

---

## 8. CSV import — `csv.m`

[routines/csv.m](routines/csv.m) reads an RFC-4180 CSV file into a global.

### Import a file

```mumps
do importFile^csv("/home/rafael/data/people.csv", "people")
```

After import the global looks like:

```
^people("headers",1) = "name"
^people("headers",2) = "age"
^people("headers",3) = "city"
^people(1,"name")    = "Alice"
^people(1,"age")     = "32"
^people(1,"city")    = "Portland"
^people("count")     = 3
```

### Display as a table

```mumps
do show^csv("people")
```

Output:

```
name             age              city
-------------------------------------------------
Alice            32               Portland
Bob              28               Seattle
```

### Visualize the raw structure

```mumps
do show^gtree("people")
```

### Handles RFC-4180 edge cases

The parser correctly handles:
- Quoted fields: `"Smith, Bob",30`
- Embedded commas inside quotes: `"Portland, OR",engineer`
- Doubled quotes (escaped literal `"`): `"a""b"` → `a"b`

### Uses `require^safe` for validation

```mumps
do require^safe(path'="", "path is required")
do require^safe(gname'="", "gname is required")
```

If you call `importFile` with an empty path or global name, a clear error is
raised instead of a cryptic crash.

---

## 9. Persistent task manager — `tasks.m`

[routines/tasks.m](routines/tasks.m) is a complete working application built on
everything covered above. It stores tasks in `^tasks` and `^taskSeq`.

### Global layout

```
^tasks(id)           = title string
^tasks(id,"done")    = 0 or 1
^tasks(id,"created") = $horolog timestamp
^taskSeq             = last-used ID counter
```

### Writing tasks

```mumps
; Add a task — returns the new ID
new id
set id=$$add^tasks("Buy groceries")
write "Created task ",id,!

; Mark complete / reopen
do done^tasks(id)
do undone^tasks(id)

; Delete permanently
do del^tasks(id)
```

### Reading tasks

```mumps
; Check existence
write $$exists^tasks(id),!         ; 1 or 0

; Get the title
write $$getTitle^tasks(id),!

; Check status
write $$isDone^tasks(id),!         ; 1=done, 0=open, ""=not found

; Counts
write $$count^tasks(),!            ; total tasks
write $$countOpen^tasks(),!        ; only open tasks
```

### Display

```mumps
do list^tasks()       ; formatted list with [ ] / [x] markers
do show^tasks()       ; raw ^tasks tree via gtree
```

### Bulk operations

```mumps
set deleted=$$clearDone^tasks()    ; removes all completed tasks, returns count
do clearAll^tasks()                ; wipes everything (use with care)
```

### `$INCREMENT` for atomic IDs

```mumps
set id=$increment(^taskSeq)
```

`$INCREMENT` atomically increments a global node and returns the new value.
It guarantees unique IDs even in concurrent processes — the YottaDB equivalent
of an auto-increment primary key.

### `$QUIT` for dual-mode functions

`add^tasks` can be called two ways:

```mumps
set id=$$add^tasks("Buy milk")   ; as a function — returns the ID
do add^tasks("Buy milk")         ; as a subroutine — ID discarded
```

It handles both with:

```mumps
if $quit quit id    ; return id when called as $$
quit                ; silent when called as do
```

---

## 10. Writing and running tests

### The test runner — `TESTRUN.m`

[routines/tests/TESTRUN.m](routines/tests/TESTRUN.m) is the assertion library.
It is not a framework that discovers tests automatically — you call it directly.

#### Assertion functions

| Call | Meaning |
|------|---------|
| `do start^TESTRUN(.pass,.fail)` | Initialize pass/fail counters |
| `do eq^TESTRUN(.pass,.fail,actual,expected,"desc")` | Assert `actual=expected` |
| `do ok^TESTRUN(.pass,.fail,condition,"desc")` | Assert condition is truthy |
| `do report^TESTRUN(pass,fail)` | Print summary; `halt` with error code if any failures |

The `.` prefix passes counters by reference so the library can increment them.

#### Output format

```
  PASS  greet(World)
  PASS  greet(Alice)
  FAIL  shout(alice)
         expected: =HELLO, ALICE!
         actual:   =Hello, Alice!

Results: 4 tests  3 passed  1 failed
1 test(s) FAILED.
```

### Structure of a test suite

Every test suite follows the same pattern — see [HELLOTST.m](routines/tests/HELLOTST.m)
as the simplest example:

```mumps
HELLOTST        ; Test suite — run with: ydb -run ^HELLOTST
        new pass,fail
        do start^TESTRUN(.pass,.fail)
        ;
        do tGreetWorld(.pass,.fail)
        do tGreetName(.pass,.fail)
        ;
        do report^TESTRUN(pass,fail)
        quit
        ;
tGreetWorld(pass,fail)
        new result
        set result=$$greet^hello("World")
        do eq^TESTRUN(.pass,.fail,result,"Hello, World!","greet(World)")
        quit
```

Key conventions:
- The suite's entry label matches the filename (`HELLOTST`).
- Each test is a sub-label prefixed with `t` (e.g. `tGreetWorld`).
- Tests receive `pass` and `fail` by reference (`.pass,.fail`).
- Always `new` local variables at the top of each test.

### Naming convention

| File | Tests |
|------|-------|
| `routines/hello.m` | `routines/tests/HELLOTST.m` |
| `routines/globals.m` | `routines/tests/GLOBALTST.m` |
| `routines/safe.m` | `routines/tests/SAFETST.m` |
| `routines/gtree.m` | `routines/tests/GTREETST.m` |
| `routines/strfns.m` | `routines/tests/STRFNSTST.m` |
| `routines/csv.m` | `routines/tests/CSVTST.m` |
| `routines/tasks.m` | `routines/tests/TASKSTST.m` |

### Running tests

```bash
make test                      # run all suites
ydb -run ^HELLOTST             # run one suite
ydb -run ^TASKSTST             # run task tests
make watch                     # re-run on every file save (requires entr)
```

### Test isolation — cleaning up globals

Tests that write globals must clean up before and/or after. The pattern used
throughout this project:

```mumps
clean   ; local helper that resets state
        do clearAll^tasks()        ; or: kill ^demo
        quit

tSomeTest(pass,fail)
        do clean                   ; clean before this test
        ; ... test body ...
        quit
```

Alternatively, use `kill ^globalName` directly at the start of each test.

### Testing errors with `tryCatch`

To assert that a function raises an error:

```mumps
tAddRequiresTitle(pass,fail)
        new ok,errMsg
        do tryCatch^safe("set id=$$add^tasks("""")",.ok,.errMsg)
        do eq^TESTRUN(.pass,.fail,ok,0,"empty title raises error")
        quit
```

### Writing a new routine — TDD workflow

1. Create `routines/myroutine.m` with stub labels that `quit` immediately.
2. Create `routines/tests/MYROUTINETST.m` with failing tests.
3. Add `@$(YDB) -run ^MYROUTINETST` to the `test` target in the Makefile.
4. Run `make watch` and implement until all tests pass.

---

## Quick reference

### Call syntax cheat sheet

```mumps
do routine^file             ; run subroutine, discard return value
set x=$$func^file(arg)     ; call function, capture return value
do label^file(.var)         ; pass variable by reference (dot prefix)
```

### Key intrinsic functions

```mumps
$GET(node)                  ; safe read — returns "" if missing
$GET(node,"default")        ; safe read with default
$DATA(node)                 ; 0=missing, 1=value, 10=children, 11=both
$ORDER(^global(key))        ; next key in collation order
$INCREMENT(^counter)        ; atomic increment, returns new value
$LENGTH(str)                ; string length
$PIECE(str,delim,n)         ; nth delimited field (1-based)
$EXTRACT(str,from,to)       ; substring (1-based, inclusive)
$FIND(str,target)           ; position AFTER match, or 0
$ZCONVERT(str,"U"/"L")      ; uppercase / lowercase
$HOROLOG                    ; current date+time (YottaDB internal format)
```

### Error handling

```mumps
new $ETRAP                  ; scope the error handler to this call frame
set $ETRAP="..."            ; set handler code string
set $ECODE=""               ; clear current error (resume execution)
$ZSTATUS                    ; human-readable error description
$QUIT                       ; 1 if return value expected, 0 if subroutine
```
