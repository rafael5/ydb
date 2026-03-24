idx ; Secondary index utilities — cross-reference globals for fast lookups.
    ;
    ; Pattern: ^primaryGbl(id) = data
    ;          ^indexGbl(key,id) = ""    ← secondary index
    ;
    ; A secondary index maps a derived key (e.g. status, first letter) back
    ; to the IDs that have that value. $ORDER on the index gives fast lookups
    ; without scanning every record.
    ;
    ; This module provides generic index operations plus a concrete example:
    ; indexes on the ^tasks global.
    quit
    ;
; ── Generic index operations ─────────────────────────────────────────────────
    ;
; add(idxGbl,key,id) — add one (key→id) entry to an index global
;   idxGbl — global reference string, e.g. "^tasksByDone"
;   key    — index key value (string or number)
;   id     — record identifier
add(idxGbl,key,id)
    set @idxGbl@(key,id)=""
    quit
    ;
; remove(idxGbl,key,id) — remove one entry from an index global
remove(idxGbl,key,id)
    kill @idxGbl@(key,id)
    quit
    ;
; lookup(idxGbl,key,.results) — retrieve all IDs for a given key
;   results(1..n) = id values in collation order
;   returns count
lookup(idxGbl,key,results)
    new id,n
    set n=0,id=""
    for  set id=$order(@idxGbl@(key,id))  quit:id=""  do
    .  set n=n+1
    .  set results(n)=id
    quit n
    ;
; count(idxGbl,key) — count entries for a key without building a result array
count(idxGbl,key)
    new id,n
    set n=0,id=""
    for  set id=$order(@idxGbl@(key,id))  quit:id=""  set n=n+1
    quit n
    ;
; ── Tasks-specific indexes ────────────────────────────────────────────────────
    ;
    ; ^tasksByDone(done,id) = ""    — lookup by completion status (0 or 1)
    ; ^tasksByFirst(char,id) = ""   — lookup by first character of title
    ;
; build() — (re)build all task indexes from the current ^tasks data
build()
    new id,done,ch
    kill ^tasksByDone,^tasksByFirst
    set id=""
    for  set id=$order(^tasks(id))  quit:id=""  do
    .  set done=$get(^tasks(id,"done"),0)
    .  set ch=$extract($get(^tasks(id)),1)
    .  set ^tasksByDone(done,id)=""
    .  if ch'=""  set ^tasksByFirst(ch,id)=""
    quit
    ;
; indexAdd(id) — update indexes when a new task is added
indexAdd(id)
    new done,ch
    set done=$get(^tasks(id,"done"),0)
    set ch=$extract($get(^tasks(id)),1)
    set ^tasksByDone(done,id)=""
    if ch'=""  set ^tasksByFirst(ch,id)=""
    quit
    ;
; indexStatus(id,wasDone) — update done-index when status changes
;   wasDone — the previous done value (before the change)
indexStatus(id,wasDone)
    new isDone
    set isDone=$get(^tasks(id,"done"),0)
    kill ^tasksByDone(wasDone,id)
    set ^tasksByDone(isDone,id)=""
    quit
    ;
; indexDel(id,wasDone,title) — remove from indexes when task is deleted
indexDel(id,wasDone,title)
    new ch
    set ch=$extract(title,1)
    kill ^tasksByDone(wasDone,id)
    if ch'=""  kill ^tasksByFirst(ch,id)
    quit
    ;
; ── Query helpers ──────────────────────────────────────────────────────────────
    ;
; byDone(done,.results) — get IDs of tasks with given done flag; returns count
byDone(done,results)
    quit $$lookup("^tasksByDone",done,.results)
    ;
; byFirst(ch,.results) — get IDs of tasks whose title starts with ch; returns count
byFirst(ch,results)
    quit $$lookup("^tasksByFirst",ch,.results)
    ;
; countOpen() — count open tasks via index (O(open) not O(all))
countOpen()
    quit $$count("^tasksByDone",0)
    ;
; countDone() — count completed tasks via index
countDone()
    quit $$count("^tasksByDone",1)
