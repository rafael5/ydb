txn ; Transaction utilities — atomic multi-global operations.
    ; Wraps TSTART/TCOMMIT/TROLLBACK patterns for safe use.
    quit
    ;
; run(code,.ok,.err) — execute MUMPS code atomically
;   If code raises an error, the transaction is rolled back automatically.
;   ok  — set to 1 on commit, 0 on rollback
;   err — set to error message on rollback, "" on success
;   Example: do run^txn("set ^a=1 set ^b=2",.ok,.err)
run(code,ok,err)
    new $etrap
    set ok=1,err=""
    ; On error: rollback if inside txn, capture message, clear error so execution continues
    set $etrap="if $tlevel trollback  set ok=0  set err=$zstatus  set $ecode="""""
    tstart ():serial
    xecute code
    if $tlevel  tcommit
    quit
    ;
; transfer(from,to,amount) — move amount between two globals atomically
;   from, to — global references as strings (e.g. "^acct(""alice"")")
;   amount   — positive number to transfer
;   Returns 1 on success, 0 if from has insufficient balance
;   Example: set ok=$$transfer^txn("^acct(""alice"")","^acct(""bob"")",50)
transfer(from,to,amount)
    new ok,bal
    set ok=1
    tstart ():serial
    set bal=$get(@from,0)
    if bal<amount  trollback  set ok=0  quit ok
    set @from=bal-amount
    set @to=$get(@to,0)+amount
    tcommit
    quit ok
    ;
; level() — current transaction nesting depth (0 = not in a transaction)
level()
    quit $tlevel
    ;
; inTxn() — 1 if currently inside a transaction, 0 otherwise
inTxn()
    if $tlevel  quit 1
    quit 0
