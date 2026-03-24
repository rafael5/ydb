strfns  ; String utility functions — named wrappers around MUMPS built-ins.
        ;
        ; MUMPS string functions quick reference:
        ;
        ;   $PIECE(str,delim,n)       → nth delimited field (1-based)
        ;   $PIECE(str,delim,n,m)     → fields n through m joined by delim
        ;   $LENGTH(str)              → character count
        ;   $LENGTH(str,delim)        → number of delimited fields
        ;   $EXTRACT(str,from,to)     → substring (1-based, inclusive)
        ;   $FIND(str,target)         → position AFTER target, or 0 if not found
        ;   $TRANSLATE(str,from,to)   → replace characters (like tr in bash)
        ;   $ZCONVERT(str,"U"/"L")    → uppercase / lowercase
        ;   $ASCII(str,n)             → ASCII code of nth character
        ;   $CHAR(n)                  → character from ASCII code
        ;   $REVERSE(str)             → reverse the string (YottaDB extension)
        ;
        quit
        ;
; ── Decomposition ─────────────────────────────────────────────────────────────
        ;
piece(str,delim,n)
        ; Get the nth delimited field (1-based). The workhorse of MUMPS strings.
        ;   piece("alice,30,portland",",",2)  →  "30"
        quit $piece(str,delim,n)
        ;
count(str,delim)
        ; Count delimited fields.
        ;   count("a,b,c",",")  →  3
        ;   count("",",")       →  1  (one empty field)
        quit $length(str,delim)
        ;
sub(str,from,to)
        ; Substring from position 'from' to 'to' (1-based, inclusive).
        ;   sub("hello",2,4)  →  "ell"
        quit $extract(str,from,to)
        ;
left(str,n)
        ; First n characters.
        quit $extract(str,1,n)
        ;
right(str,n)
        ; Last n characters.
        quit $extract(str,$length(str)-n+1,$length(str))
        ;
; ── Search ────────────────────────────────────────────────────────────────────
        ;
        ; NOTE: $FIND returns the position AFTER the end of the match (or 0).
        ; Example: $FIND("hello","ll") = 5  (position after "ll", which ends at 4)
        ; This is different from most languages. The find() wrapper below
        ; converts to start-of-match (more intuitive).
        ;
find(str,target)
        ; Return the start position of target in str, or 0 if not found.
        ;   find("hello world","world")  →  7
        new pos
        set pos=$find(str,target)
        if pos=0 quit 0
        quit pos-$length(target)
        ;
contains(str,target)
        ; Return 1 if target appears in str.
        quit ($find(str,target)>0)
        ;
startsWith(str,prefix)
        quit ($extract(str,1,$length(prefix))=prefix)
        ;
endsWith(str,suffix)
        new n
        set n=$length(str)-$length(suffix)+1
        quit ($extract(str,n,$length(str))=suffix)
        ;
; ── Transformation ────────────────────────────────────────────────────────────
        ;
upper(str)
        quit $zconvert(str,"U")
        ;
lower(str)
        quit $zconvert(str,"L")
        ;
trim(str)
        ; Remove leading and trailing spaces.
        for  quit:(str="")!($extract(str,1)'=" ")  set str=$extract(str,2,$length(str))
        for  quit:(str="")!($extract(str,$length(str))'=" ")  set str=$extract(str,1,$length(str)-1)
        quit str
        ;
replace(str,from,to)
        ; Replace all occurrences of 'from' with 'to' in str.
        ;   replace("hello world","o","0")  →  "hell0 w0rld"
        ;
        ; Uses $FIND in a loop. $FIND returns position AFTER match, so:
        ;   before = $EXTRACT(str, 1, pos-$LENGTH(from)-1)
        ;   after  = $EXTRACT(str, pos, $LENGTH(str))
        ;
        new pos
        for  set pos=$find(str,from)  quit:pos=0  do
        .  set str=$extract(str,1,pos-$length(from)-1)_to_$extract(str,pos,$length(str))
        quit str
        ;
translate(str,fromChars,toChars)
        ; Replace characters one-for-one (like bash tr or Python str.translate).
        ; Each char in fromChars is replaced by the corresponding char in toChars.
        ; If toChars is shorter, extra fromChars are deleted.
        ;   translate("hello","aeiou","AEIOU")  →  "hEllO"
        ;   translate("hello-world","-","_")    →  "hello_world"
        quit $translate(str,fromChars,toChars)
        ;
pad(str,width,char)
        ; Right-pad str to width with char (default space).
        ; Useful for aligned output.
        set char=$get(char," ")
        for  quit:$length(str)>=width  set str=str_char
        quit str
