TESTRUN(suite)  ; Lightweight test runner — no external dependencies
        ; Discovers and runs all labels starting with lowercase 't' in the suite.
        ; Usage:  do ^TESTRUN("HELLOTST")
        ;         ydb -run ^TESTRUN HELLOTST
        ;
        ; Exit codes: 0 = all pass, 1 = failures exist
        ;
        new pass,fail,total,label,err
        set pass=0,fail=0,total=0
        ;
        ; Discover test labels in the target routine
        set label=""
        for  set label=$TEXT(+1^@suite) quit:label=""  do
        . ; $TEXT returns source lines; we scan for labels starting with 't'
        . ; Skip — use explicit dispatch table via TESTS label in each suite
        ;
        ; Instead: call the suite's own TESTS dispatcher if present
        ; Otherwise fall back to label scanning
        if $TEXT(TESTS^@suite)'="" do TESTS^@suite
        else  do scan(suite)
        ;
        do report(pass,fail,total)
        if fail>0 halt  ; non-zero exit code for CI
        quit
        ;
scan(suite)     ; Scan for tXxx labels and call them
        new i,line,label,tag
        set i=1
        for  do  quit:label=""
        .  set line=$TEXT(@i^@suite)
        .  set label=$PIECE(line," ",1)
        .  if label="" set label="" quit   ; blank line = end of discoverable labels
        .  if $EXTRACT(label,1)="t" do call(suite,label)
        .  set i=i+1
        quit
        ;
call(suite,label)       ; Call one test and record pass/fail
        new $ETRAP
        set $ETRAP="do fail^TESTRUN"
        set total=total+1
        do @label^@suite
        set pass=pass+1
        write "  PASS  ",label,!
        quit
        ;
fail    ; Called by $ETRAP on error
        set fail=fail+1
        write "  FAIL  ",$ZSTATUS,!
        quit
        ;
eq(actual,expected,desc)        ; Assert two values are equal
        if actual=expected quit
        write "  ASSERT FAIL: ",desc,!
        write "    expected: [",expected,"]",!
        write "    actual:   [",actual,"]",!
        ; Force an error to trigger the fail handler
        set $ECODE=",U1,"
        quit
        ;
assert(cond,desc)       ; Assert a condition is true
        if cond quit
        write "  ASSERT FAIL: ",desc,!
        set $ECODE=",U1,"
        quit
        ;
report(pass,fail,total) ; Print summary
        write !
        write "Results: ",total," tests, ",pass," passed, ",fail," failed",!
        if fail=0 write "All tests passed.",!
        else  write fail," test(s) FAILED.",!
        quit
