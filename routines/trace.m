trace   ; Structured runtime tracing — log to ^trace global.
        ;
        ; Use this to instrument routines during development and debugging.
        ; Entries persist in the database and survive process restarts.
        ; Inspect with: yeval 'do dump^trace()'
        ;               gtree trace
        ;               ystate (shows recent entries automatically)
        ;
        ; Usage:
        ;   do log^trace("myRoutine","entered with x="_x)
        ;   do log^trace("myRoutine","result="_result)
        ;   do clear^trace()          ; wipe log before a debug run
        ;
        quit
        ;
; ── Write ─────────────────────────────────────────────────────────────────────
        ;
log(context,message)
        ; Append one trace entry with timestamp.
        new seq,ts
        set seq=$increment(^traceSeq)
        set ts=$horolog
        set ^trace(seq,"ts")=ts
        set ^trace(seq,"ctx")=context
        set ^trace(seq,"msg")=message
        quit
        ;
err(context,message)
        ; Log an error-level entry (prefixed so it stands out in dumps).
        do log(context,"ERROR: "_message)
        quit
        ;
; ── Read ──────────────────────────────────────────────────────────────────────
        ;
dump()
        ; Print all trace entries to stdout, most recent last.
        if '$data(^trace) write "(trace log is empty)",! quit
        ;
        new seq,ctx,msg,total
        set total=$get(^traceSeq,0)
        write "── Trace log (",total," entries) ───────────────────",!
        set seq=""
        for  set seq=$order(^trace(seq)) quit:seq=""  do
        .  set ctx=$get(^trace(seq,"ctx"),"?")
        .  set msg=$get(^trace(seq,"msg"),"?")
        .  write seq,".  [",ctx,"]  ",msg,!
        write "────────────────────────────────────────────────────",!
        quit
        ;
tail(n)
        ; Print the last n trace entries (default 20).
        set n=$get(n,20)
        if '$data(^trace) write "(trace log is empty)",! quit
        ;
        new seq,ctx,msg,total,start
        set total=$get(^traceSeq,0)
        set start=$select(total>n:total-n+1,1:1)
        ;
        write "── Last ",n," trace entries ──────────────────────────",!
        set seq=start-1
        for  set seq=$order(^trace(seq)) quit:seq=""  do
        .  set ctx=$get(^trace(seq,"ctx"),"?")
        .  set msg=$get(^trace(seq,"msg"),"?")
        .  write seq,".  [",ctx,"]  ",msg,!
        write "────────────────────────────────────────────────────",!
        quit
        ;
count()
        quit $get(^traceSeq,0)
        ;
; ── Manage ────────────────────────────────────────────────────────────────────
        ;
clear()
        ; Wipe the entire trace log.
        kill ^trace,^traceSeq
        write "Trace log cleared.",!
        quit
