globals ; Introduction to MUMPS globals
        ; Globals are persistent, hierarchical key-value stores.
        ; They live in the database (.dat file) and survive process restarts.
        ; Names start with ^ — that's how you know it's a global (not a local var).
        quit
        ;
; ── Basic set / get / kill ────────────────────────────────────────────────────
        ;
basicSet(key,value)     ; Store a value: ^demo(key)=value
        set ^demo(key)=value
        quit
        ;
basicGet(key)           ; Retrieve a value — returns "" if not found
        quit $GET(^demo(key))
        ;
basicDel(key)           ; Delete one node
        kill ^demo(key)
        quit
        ;
basicDelAll()           ; Delete entire ^demo global (all nodes)
        kill ^demo
        quit
        ;
; ── Multi-level subscripts ────────────────────────────────────────────────────
        ; Globals are trees. Subscripts are the path: ^global(level1,level2,...)
        ;
storeContact(name,field,value)  ; ^contacts(name,field)=value
        set ^contacts(name,field)=value
        quit
        ;
getContact(name,field)  ; Retrieve one field of a contact
        quit $GET(^contacts(name,field))
        ;
delContact(name)        ; Delete all data for one contact
        kill ^contacts(name)
        quit
        ;
; ── $ORDER — iterate subscripts ───────────────────────────────────────────────
        ; $ORDER(^global(key)) returns the NEXT key after key.
        ; Start with "" to get the first key. Returns "" when done.
        ;
listKeys()      ; Return comma-separated list of all keys in ^demo
        new result,key
        set result="",key=""
        for  set key=$ORDER(^demo(key)) quit:key=""  do
        . if result'="" set result=result_","
        . set result=result_key
        quit result
        ;
listContacts()  ; Return comma-separated list of contact names
        new result,name
        set result="",name=""
        for  set name=$ORDER(^contacts(name)) quit:name=""  do
        . if result'="" set result=result_","
        . set result=result_name
        quit result
        ;
listFields(name)        ; Return comma-separated list of fields for one contact
        new result,field
        set result="",field=""
        for  set field=$ORDER(^contacts(name,field)) quit:field=""  do
        . if result'="" set result=result_","
        . set result=result_field
        quit result
        ;
; ── $DATA — check node existence ─────────────────────────────────────────────
        ; $DATA returns: 0=nothing, 1=value only, 10=children only, 11=both
        ;
exists(key)     ; Returns 1 if ^demo(key) has a value, 0 otherwise
        quit ($DATA(^demo(key))#2)      ; #2 = modulo 2: true if 1 or 11
        ;
hasChildren(key)        ; Returns 1 if ^demo(key) has child nodes
        quit ($DATA(^demo(key))>9)      ; true if 10 or 11
