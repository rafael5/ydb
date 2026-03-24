json ; JSON serialization utilities.
     quit
     ;
; str(s) — serialize a string with JSON escaping
str(s)
     new out,i,ch,code
     set out=""""
     for i=1:1:$length(s) do
     .  set ch=$extract(s,i),code=$ascii(ch)
     .  if ch=""""  set out=out_"\"""  quit
     .  if ch="\"   set out=out_"\\"   quit
     .  if code=10  set out=out_"\n"   quit
     .  if code=13  set out=out_"\r"   quit
     .  if code=9   set out=out_"\t"   quit
     .  set out=out_ch
     set out=out_""""
     quit out
     ;
; num(n) — serialize a number (already numeric — no quoting)
num(n)
     quit n_""
     ;
; bool(b) — serialize a boolean (0 = false, non-zero = true)
bool(b)
     if b  quit "true"
     quit "false"
     ;
; null() — JSON null
null()
     quit "null"
     ;
; obj(.keys,.vals) — build a JSON object
;   keys(1..n) = field name strings
;   vals(1..n) = already-serialized JSON values (use str/num/bool/arr/obj)
obj(keys,vals)
     new out,i,n
     set out="{",n=0,i=0
     for  set i=$order(keys(i))  quit:i=""  do
     .  if n>0  set out=out_","
     .  set out=out_$$str(keys(i))_":"_vals(i)
     .  set n=n+1
     set out=out_"}"
     quit out
     ;
; arr(.items) — build a JSON array
;   items(1..n) = already-serialized JSON values
arr(items)
     new out,i,n
     set out="[",n=0,i=0
     for  set i=$order(items(i))  quit:i=""  do
     .  if n>0  set out=out_","
     .  set out=out_items(i)
     .  set n=n+1
     set out=out_"]"
     quit out
