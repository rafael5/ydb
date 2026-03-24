tasks   ; A persistent task manager backed by YottaDB globals.
        ;
        ; Global layout:
        ;   ^tasks(id)            = title
        ;   ^tasks(id,"done")     = 0 or 1
        ;   ^tasks(id,"created")  = $horolog timestamp (YottaDB internal time)
        ;   ^taskSeq              = last-used ID counter
        ;
        ; All IDs are integers assigned via $INCREMENT — atomic, no collisions.
        ;
        quit
        ;
; ── Write operations ──────────────────────────────────────────────────────────
        ;
add(title)
        ; Create a new task. Returns the new task ID.
        do require^safe(title'="","title is required")
        ;
        new id
        set id=$increment(^taskSeq)
        set ^tasks(id)=title
        set ^tasks(id,"done")=0
        set ^tasks(id,"created")=$horolog
        if $quit quit id    ; return id when called as $$add^tasks(...)
        quit                ; silent when called as do add^tasks(...)
        ;
done(id)
        ; Mark a task as complete.
        do require^safe($$exists(id),"task "_id_" not found")
        set ^tasks(id,"done")=1
        quit
        ;
undone(id)
        ; Reopen a completed task.
        do require^safe($$exists(id),"task "_id_" not found")
        set ^tasks(id,"done")=0
        quit
        ;
del(id)
        ; Delete a task entirely.
        do require^safe($$exists(id),"task "_id_" not found")
        kill ^tasks(id)
        quit
        ;
; ── Read operations ───────────────────────────────────────────────────────────
        ;
getTitle(id)
        ; Return the title of a task, or "" if not found.
        quit $get(^tasks(id))
        ;
isDone(id)
        ; Return 1 if the task is complete, 0 if open, "" if not found.
        if '$$exists(id) quit ""
        quit $get(^tasks(id,"done"),0)
        ;
exists(id)
        ; Return 1 if a task with this ID exists.
        quit ($data(^tasks(id))>0)
        ;
count()
        ; Return total number of tasks.
        new id,total
        set total=0,id=""
        for  set id=$order(^tasks(id)) quit:id=""  set total=total+1
        quit total
        ;
countOpen()
        ; Return number of incomplete tasks.
        new id,total
        set total=0,id=""
        for  set id=$order(^tasks(id)) quit:id=""  do
        .  if '$get(^tasks(id,"done"),0) set total=total+1
        quit total
        ;
; ── Display ───────────────────────────────────────────────────────────────────
        ;
list()
        ; Print all tasks, open tasks first then done, with status indicators.
        new id,done,marker
        set id=""
        ;
        write !,"Tasks:",!
        write "──────────────────────────────────────",!
        ;
        ; Two passes: open tasks first, then done
        do listByStatus(0)
        do listByStatus(1)
        ;
        write "──────────────────────────────────────",!
        write $$countOpen()," open  /  ",$$count()," total",!
        quit
        ;
listByStatus(showDone)
        ; Print tasks matching the given done status (0=open, 1=done).
        new id,marker,title
        set id=""
        for  set id=$order(^tasks(id)) quit:id=""  do
        .  if $get(^tasks(id,"done"),0)'=showDone quit
        .  set title=$get(^tasks(id),"(no title)")
        .  if showDone set marker="[x]"
        .  else  set marker="[ ]"
        .  write marker," ",id,".  ",title,!
        quit
        ;
show()
        ; Dump the raw ^tasks global as a tree (uses gtree).
        do show^gtree("tasks")
        quit
        ;
; ── Bulk operations ───────────────────────────────────────────────────────────
        ;
clearDone()
        ; Delete all completed tasks. Returns count of deleted tasks.
        new id,next,deleted
        set deleted=0,id=""
        for  set id=$order(^tasks(id)) quit:id=""  do
        .  if $get(^tasks(id,"done"),0)=1 do
        .  .  kill ^tasks(id)
        .  .  set deleted=deleted+1
        quit deleted
        ;
clearAll()
        ; Delete everything. Use with care.
        kill ^tasks,^taskSeq
        quit
