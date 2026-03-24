TESTRUN ; Assertion library for MUMPS unit tests
        ; Each test suite calls these helpers directly — no label scanning.
        ;
        ; Usage in a test suite:
        ;   new pass,fail
        ;   do start^TESTRUN(.pass,.fail)
        ;   do tMyTest(.pass,.fail)
        ;   do report^TESTRUN(pass,fail)
        quit
        ;
start(pass,fail)        ; Initialize counters (call with . to pass by reference)
        set pass=0,fail=0
        quit
        ;
eq(pass,fail,actual,expected,desc)      ; Assert actual=expected
        if actual=expected do pass^TESTRUN(.pass,desc) quit
        do fail^TESTRUN(.fail,desc,"="_expected,"="_actual)
        quit
        ;
ok(pass,fail,cond,desc) ; Assert a condition is true
        if cond do pass^TESTRUN(.pass,desc) quit
        do fail^TESTRUN(.fail,desc,"true","false")
        quit
        ;
pass(pass,desc) ; Record a passing assertion
        set pass=pass+1
        write "  PASS  ",desc,!
        quit
        ;
fail(fail,desc,expected,actual) ; Record a failing assertion
        set fail=fail+1
        write "  FAIL  ",desc,!
        write "         expected: ",expected,!
        write "         actual:   ",actual,!
        quit
        ;
report(pass,fail)       ; Print summary; halt with error if any failures
        new total
        set total=pass+fail
        write !,"Results: ",total," tests  ",pass," passed  ",fail," failed",!
        if fail=0 write "All tests passed.",! quit
        write fail," test(s) FAILED.",!
        halt
        quit
