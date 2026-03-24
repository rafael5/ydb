STRFNSTST       ; Tests for strfns.m
        new pass,fail
        do start^TESTRUN(.pass,.fail)
        ;
        do tPiece(.pass,.fail)
        do tCount(.pass,.fail)
        do tSub(.pass,.fail)
        do tLeft(.pass,.fail)
        do tRight(.pass,.fail)
        do tFind(.pass,.fail)
        do tFindMissing(.pass,.fail)
        do tContains(.pass,.fail)
        do tStartsWith(.pass,.fail)
        do tEndsWith(.pass,.fail)
        do tUpper(.pass,.fail)
        do tLower(.pass,.fail)
        do tTrimLeading(.pass,.fail)
        do tTrimTrailing(.pass,.fail)
        do tTrimBoth(.pass,.fail)
        do tTrimClean(.pass,.fail)
        do tReplace(.pass,.fail)
        do tReplaceMultiple(.pass,.fail)
        do tReplaceNone(.pass,.fail)
        do tTranslate(.pass,.fail)
        do tPad(.pass,.fail)
        ;
        do report^TESTRUN(pass,fail)
        quit
        ;
; ── $PIECE ────────────────────────────────────────────────────────────────────
        ;
tPiece(pass,fail)       ;@TEST "$PIECE: get nth delimited field"
        do eq^TESTRUN(.pass,.fail,$$piece^strfns("alice,30,portland",",",1),"alice","field 1")
        do eq^TESTRUN(.pass,.fail,$$piece^strfns("alice,30,portland",",",2),"30","field 2")
        do eq^TESTRUN(.pass,.fail,$$piece^strfns("alice,30,portland",",",3),"portland","field 3")
        do eq^TESTRUN(.pass,.fail,$$piece^strfns("alice,30,portland",",",4),"","field 4 (missing)")
        quit
        ;
tCount(pass,fail)       ;@TEST "$LENGTH(str,delim): count delimited fields"
        do eq^TESTRUN(.pass,.fail,$$count^strfns("a,b,c",","),3,"3 fields")
        do eq^TESTRUN(.pass,.fail,$$count^strfns("only",","),1,"no delimiters = 1 field")
        do eq^TESTRUN(.pass,.fail,$$count^strfns("a,,c",","),3,"empty middle field counts")
        quit
        ;
; ── $EXTRACT ─────────────────────────────────────────────────────────────────
        ;
tSub(pass,fail)         ;@TEST "$EXTRACT: substring by position"
        do eq^TESTRUN(.pass,.fail,$$sub^strfns("hello",2,4),"ell","positions 2-4")
        do eq^TESTRUN(.pass,.fail,$$sub^strfns("hello",1,1),"h","first char")
        do eq^TESTRUN(.pass,.fail,$$sub^strfns("hello",5,5),"o","last char")
        quit
        ;
tLeft(pass,fail)        ;@TEST "left: first n characters"
        do eq^TESTRUN(.pass,.fail,$$left^strfns("hello world",5),"hello","left 5")
        quit
        ;
tRight(pass,fail)       ;@TEST "right: last n characters"
        do eq^TESTRUN(.pass,.fail,$$right^strfns("hello world",5),"world","right 5")
        quit
        ;
; ── $FIND ─────────────────────────────────────────────────────────────────────
        ;
tFind(pass,fail)        ;@TEST "find: returns start position of match"
        do eq^TESTRUN(.pass,.fail,$$find^strfns("hello world","world"),7,"found at 7")
        do eq^TESTRUN(.pass,.fail,$$find^strfns("hello world","hello"),1,"found at 1")
        do eq^TESTRUN(.pass,.fail,$$find^strfns("hello world","lo"),4,"found at 4")
        quit
        ;
tFindMissing(pass,fail) ;@TEST "find: returns 0 when not found"
        do eq^TESTRUN(.pass,.fail,$$find^strfns("hello","xyz"),0,"not found = 0")
        quit
        ;
tContains(pass,fail)    ;@TEST "contains: boolean substring check"
        do eq^TESTRUN(.pass,.fail,$$contains^strfns("hello world","world"),1,"contains true")
        do eq^TESTRUN(.pass,.fail,$$contains^strfns("hello world","xyz"),0,"contains false")
        quit
        ;
tStartsWith(pass,fail)  ;@TEST "startsWith: prefix check"
        do eq^TESTRUN(.pass,.fail,$$startsWith^strfns("hello","hel"),1,"starts with hel")
        do eq^TESTRUN(.pass,.fail,$$startsWith^strfns("hello","world"),0,"not starts with world")
        quit
        ;
tEndsWith(pass,fail)    ;@TEST "endsWith: suffix check"
        do eq^TESTRUN(.pass,.fail,$$endsWith^strfns("hello","llo"),1,"ends with llo")
        do eq^TESTRUN(.pass,.fail,$$endsWith^strfns("hello","hel"),0,"not ends with hel")
        quit
        ;
; ── Case ─────────────────────────────────────────────────────────────────────
        ;
tUpper(pass,fail)       ;@TEST "upper: $ZCONVERT to uppercase"
        do eq^TESTRUN(.pass,.fail,$$upper^strfns("hello World"),"HELLO WORLD","upper")
        quit
        ;
tLower(pass,fail)       ;@TEST "lower: $ZCONVERT to lowercase"
        do eq^TESTRUN(.pass,.fail,$$lower^strfns("Hello WORLD"),"hello world","lower")
        quit
        ;
; ── Trim ─────────────────────────────────────────────────────────────────────
        ;
tTrimLeading(pass,fail) ;@TEST "trim: removes leading spaces"
        do eq^TESTRUN(.pass,.fail,$$trim^strfns("   hello"),"hello","trim leading")
        quit
        ;
tTrimTrailing(pass,fail)        ;@TEST "trim: removes trailing spaces"
        do eq^TESTRUN(.pass,.fail,$$trim^strfns("hello   "),"hello","trim trailing")
        quit
        ;
tTrimBoth(pass,fail)    ;@TEST "trim: removes both ends"
        do eq^TESTRUN(.pass,.fail,$$trim^strfns("  hello  "),"hello","trim both")
        quit
        ;
tTrimClean(pass,fail)   ;@TEST "trim: no-op on already-clean string"
        do eq^TESTRUN(.pass,.fail,$$trim^strfns("hello"),"hello","trim clean string")
        quit
        ;
; ── Replace / Translate ───────────────────────────────────────────────────────
        ;
tReplace(pass,fail)     ;@TEST "replace: substitutes first and subsequent matches"
        do eq^TESTRUN(.pass,.fail,$$replace^strfns("hello world","o","0"),"hell0 w0rld","replace o→0")
        quit
        ;
tReplaceMultiple(pass,fail)     ;@TEST "replace: works with multi-char from and to"
        do eq^TESTRUN(.pass,.fail,$$replace^strfns("aabbaa","aa","X"),"XbbX","replace multi-char")
        quit
        ;
tReplaceNone(pass,fail) ;@TEST "replace: no change when pattern absent"
        do eq^TESTRUN(.pass,.fail,$$replace^strfns("hello","xyz","ZZZ"),"hello","replace no match")
        quit
        ;
tTranslate(pass,fail)   ;@TEST "$TRANSLATE: character-level substitution"
        do eq^TESTRUN(.pass,.fail,$$translate^strfns("hello","aeiou","AEIOU"),"hEllO","vowels upper")
        do eq^TESTRUN(.pass,.fail,$$translate^strfns("a-b_c","-_","  "),"a b c","punctuation to spaces")
        quit
        ;
tPad(pass,fail)         ;@TEST "pad: right-pads to width"
        do eq^TESTRUN(.pass,.fail,$$pad^strfns("hi",6),"hi    ","pad to 6")
        do eq^TESTRUN(.pass,.fail,$$pad^strfns("hello",6),"hello ","pad to 6 one char")
        do eq^TESTRUN(.pass,.fail,$$pad^strfns("toolong",3),"toolong","no truncation if already wide")
        quit
