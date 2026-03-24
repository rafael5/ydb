HELLOTST        ; Test suite for hello.m
        ; Uses the lightweight built-in test runner (see routines/tests/TESTRUN.m)
        ; Run via:  make test
        ;           ydb -run ^TESTRUN HELLOTST
        ;
        do ^TESTRUN("HELLOTST")
        quit
        ;
; ---- Tests (each label starting with 't' is auto-discovered) ---------------
        ;
tGreetWorld     ;@TEST "greet() returns correct string for 'World'"
        new result
        set result=$$greet^hello("World")
        do eq^TESTRUN(result,"Hello, World!","greet(World)")
        quit
        ;
tGreetName      ;@TEST "greet() works with any name"
        new result
        set result=$$greet^hello("Alice")
        do eq^TESTRUN(result,"Hello, Alice!","greet(Alice)")
        quit
        ;
tShoutUppercase ;@TEST "shout() uppercases the name"
        new result
        set result=$$shout^hello("alice")
        do eq^TESTRUN(result,"HELLO, ALICE!","shout(alice)")
        quit
        ;
tShoutAlreadyUpper      ;@TEST "shout() handles already-uppercase name"
        new result
        set result=$$shout^hello("BOB")
        do eq^TESTRUN(result,"HELLO, BOB!","shout(BOB)")
        quit
