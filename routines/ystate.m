ystate  ; System state inspection — called by bin/ystate.
        ; All output goes to stdout for the shell script to display.
        quit
        ;
globals()
        ; List all user globals with their top-level node count.
        new gbl,sub,count,found
        set gbl="",found=0
        ;
        for  set gbl=$order(^%(gbl))  quit:gbl=""  do
        .  set count=0,sub=""
        .  for  set sub=$order(@("^"_gbl_"("""_sub_"""")"))  quit:sub=""  set count=count+1
        .  write "  ^",gbl," (",count," top-level nodes)",$char(10)
        .  set found=1
        ;
        if 'found write "  (no user globals)",$char(10)
        quit
        ;
trace(n)
        ; Print the last n trace entries.
        set n=$get(n,20)
        do tail^trace(n)
        quit
        ;
traceCount()
        write $$count^trace(),$char(10)
        quit
