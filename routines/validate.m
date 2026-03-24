validate ; Input validation — check values against rule strings.
         quit
         ;
; check(value, rules, .error)
;   rules  — pipe-separated specs, e.g. "required|minlen:2|maxlen:50|number"
;   error  — set to first failing message, or "" if all pass (by reference)
;   return — 1 if valid, 0 if not
check(value,rules,error)
         new i,n,rule,name,arg,ok
         set error="",ok=1,n=$length(rules,"|")
         for i=1:1:n  do  quit:'ok
         .  set rule=$piece(rules,"|",i)
         .  set name=$piece(rule,":",1)
         .  set arg=$piece(rule,":",2,99)
         .  set ok=$$applyRule(value,name,arg,.error)
         quit ok
         ;
applyRule(value,name,arg,error)
         if name="required"  quit $$required(value,.error)
         if name="minlen"    quit $$minlen(value,+arg,.error)
         if name="maxlen"    quit $$maxlen(value,+arg,.error)
         if name="number"    quit $$number(value,.error)
         if name="integer"   quit $$integer(value,.error)
         if name="range"     quit $$range(value,$piece(arg,",",1),$piece(arg,",",2),.error)
         if name="inlist"    quit $$inlist(value,arg,.error)
         if name="minval"    quit $$minval(value,+arg,.error)
         if name="maxval"    quit $$maxval(value,+arg,.error)
         quit 1
         ;
required(value,error)
         if value=""  set error="is required"  quit 0
         quit 1
         ;
minlen(value,n,error)
         if $length(value)<n  set error="must be at least "_n_" characters"  quit 0
         quit 1
         ;
maxlen(value,n,error)
         if $length(value)>n  set error="must be at most "_n_" characters"  quit 0
         quit 1
         ;
number(value,error)
         if value=""  set error="must be a number"  quit 0
         if value'=+value  set error="must be a number"  quit 0
         quit 1
         ;
integer(value,error)
         if value=""  set error="must be an integer"  quit 0
         if value'=+value  set error="must be an integer"  quit 0
         if +value'=$fnumber(+value,"",0)  set error="must be an integer"  quit 0
         quit 1
         ;
range(value,min,max,error)
         if value<min  set error="must be >= "_min  quit 0
         if value>max  set error="must be <= "_max  quit 0
         quit 1
         ;
minval(value,min,error)
         if value<min  set error="must be >= "_min  quit 0
         quit 1
         ;
maxval(value,max,error)
         if value>max  set error="must be <= "_max  quit 0
         quit 1
         ;
inlist(value,list,error)
         new i,n,found
         set found=0,n=$length(list,",")
         for i=1:1:n  quit:found  if $piece(list,",",i)=value  set found=1
         if 'found  set error="must be one of: "_list  quit 0
         quit 1
