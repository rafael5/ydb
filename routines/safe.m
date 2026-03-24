safe    ; Protected/safe operations — error handling patterns for YottaDB.
        ;
        ; MUMPS error handling vocabulary:
        ;
        ;   $ETRAP   — a string of MUMPS code executed when an error occurs.
        ;              Use "new $ETRAP" to scope it: restored on quit, like try/finally.
        ;
        ;   $ECODE   — the active error code, e.g. ",M9," (divide by zero).
        ;              Set $ECODE="" to clear the error and resume execution.
        ;              Leave it set and it propagates up the call stack.
        ;
        ;   $ZSTATUS — the full human-readable error string from YottaDB.
        ;              e.g. "150372210,divide+1^safe,%YDB-E-DIVZERO,..."
        ;
        ;   $QUIT    — 1 if the current context expects a return value ($$func),
        ;              0 if called as a subroutine (do sub).
        ;              Use in $ETRAP to quit correctly from either context.
        ;
        quit
        ;
; ── Safe wrappers ─────────────────────────────────────────────────────────────
        ;
divide(a,b)
        ; Divide a by b. Returns "" instead of crashing on divide-by-zero.
        ;
        new $ETRAP,result
        set $ETRAP="set result="""" set $ECODE="""""  ; clear error, return ""
        set result=a/b
        quit result
        ;
get(gname,key,default)
        ; Safe global get: returns default (or "") if node is missing or gname is bad.
        ; Equivalent to Python's dict.get(key, default).
        ;
        new $ETRAP,result
        set default=$get(default,"")
        set $ETRAP="set result=default set $ECODE="""""
        set result=$get(@("^"_gname_"("""_key_""")"),default)
        quit result
        ;
; ── User-defined errors (like raise in Python) ────────────────────────────────
        ;
        ; U1–U999 are reserved for user-defined errors in YottaDB.
        ; Raise one by setting $ECODE=",U<n>,".
        ; The caller's $ETRAP fires exactly as with system errors.
        ;
require(cond,msg)
        ; Assert a precondition. Raises a user error (U1) if cond is false.
        ; Use this at the top of routines to validate input.
        ;
        ; Example:  do require^safe(age>0,"age must be positive")
        ;           do require^safe(name'="","name is required")
        ;
        if cond quit
        set ^lastError=msg          ; stash message so $ETRAP handler can read it
        set $ECODE=",U1,"           ; raise — caller's $ETRAP fires
        quit
        ;
lastError()
        ; Return the message from the most recent require() failure.
        quit $get(^lastError,"")
        ;
; ── Catching errors — the try/catch pattern ───────────────────────────────────
        ;
        ; The standard MUMPS try/catch pattern:
        ;
        ;   new $ETRAP,ok,errMsg
        ;   set ok=1,errMsg=""
        ;   set $ETRAP="set ok=0,errMsg=$zstatus set $ECODE="""""
        ;   ; ... code that might fail ...
        ;   if 'ok do handleError(errMsg)
        ;
        ; The $ETRAP string runs on error. Setting $ECODE="" clears the error
        ; so execution continues after the failing line (not before it).
        ;
tryCatch(code,ok,errMsg)
        ; Execute a string of MUMPS code. Sets ok=1 on success, ok=0 on error.
        ; errMsg is set to $ZSTATUS if an error occurred.
        ;
        ; Example:
        ;   new ok,errMsg
        ;   do tryCatch^safe("set x=1/0",.ok,.errMsg)
        ;   if 'ok write "caught: ",errMsg,!
        ;
        new $ETRAP
        set ok=1,errMsg=""
        set $ETRAP="set ok=0,errMsg=$zstatus set $ECODE="""""
        xecute code
        quit
