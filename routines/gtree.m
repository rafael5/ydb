gtree   ; Visualize a YottaDB global as a tree, like the `tree` command.
        ;
        ; Usage:
        ;   do show^gtree("contacts")
        ;   do show^gtree("^contacts")   ; leading ^ is accepted too
        ;
        ; Output:
        ;   ^contacts
        ;   ├── Alice
        ;   │   ├── city: Portland
        ;   │   ├── email: alice@example.com
        ;   │   └── phone: 555-1234
        ;   └── Bob
        ;       └── phone: 555-9999
        ;
        quit
        ;
; ── Public ────────────────────────────────────────────────────────────────────
        ;
show(gname)
        ; Entry point. strip leading ^ if present, then draw the tree.
        if $extract(gname,1)="^" set gname=$extract(gname,2,$length(gname))
        ;
        new path                ; path(depth) = subscript at each level
        write "^",gname,!
        ;
        if '$data(@("^"_gname)) write "(empty)",! quit
        do walk(gname,1,"")
        quit
        ;
; ── Private ───────────────────────────────────────────────────────────────────
        ;
walk(gname,depth,prefix)
        ; Iterate all subscripts at this depth level and draw them.
        ; 'path' is inherited from show() — we update it as we descend.
        ;
        new key,nextKey,connector,childPrefix,data,val
        ;
        set key=$order(@$$mkref(gname,depth,""))
        for  quit:key=""  do
        .  set nextKey=$order(@$$mkref(gname,depth,key))
        .  set path(depth)=key
        .  ;
        .  ; last sibling gets └──, others get ├──
        .  if nextKey'="" do
        .  .  set connector="├── "
        .  .  set childPrefix=prefix_"│   "
        .  else  do
        .  .  set connector="└── "
        .  .  set childPrefix=prefix_"    "
        .  ;
        .  ; $data: 0=nothing  1=value only  10=children only  11=value+children
        .  set data=$data(@$$mkref(gname,depth,key))
        .  set val=$get(@$$mkref(gname,depth,key))
        .  ;
        .  if data#2 write prefix,connector,key,": ",val,!  ; has a value
        .  else       write prefix,connector,key,!           ; branch node only
        .  ;
        .  if data>9 do walk(gname,depth+1,childPrefix)      ; recurse into children
        .  ;
        .  set key=nextKey
        ;
        kill path(depth)        ; restore path before returning to parent level
        quit
        ;
mkref(gname,depth,curKey)
        ; Build a YottaDB reference string for use with $order and $data.
        ;
        ; mkref("contacts", 1, "Alice")           → ^contacts("Alice")
        ; mkref("contacts", 2, "phone")            → ^contacts("Alice","phone")
        ;   (where path(1)="Alice" is already set)
        ; mkref("contacts", 1, "")                 → ^contacts("")   (for $order start)
        ;
        new result,i
        set result="^"_gname_"("
        for i=1:1:depth-1 set result=result_""""_path(i)_""","
        set result=result_""""_curKey_""")"
        quit result
