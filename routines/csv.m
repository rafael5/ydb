csv     ; CSV file reader and global importer.
        ;
        ; Parses RFC-4180 CSV: quoted fields, embedded commas, escaped quotes.
        ; Imports into a global with this layout:
        ;
        ;   ^gname("headers",1)     = "name"
        ;   ^gname("headers",2)     = "age"
        ;   ^gname(1,"name")        = "Alice"
        ;   ^gname(1,"age")         = "32"
        ;   ^gname("count")         = 3
        ;
        ; Usage:
        ;   do importFile^csv("/path/to/file.csv","people")
        ;   do show^csv("people")
        ;   do show^gtree("people")
        ;
        quit
        ;
; ── Public API ────────────────────────────────────────────────────────────────
        ;
importFile(path,gname)
        ; Read a CSV file and import it into ^gname.
        ; First line is treated as headers.
        do require^safe(path'="","path is required")
        do require^safe(gname'="","gname is required")
        ;
        new line,rowNum,headerCount
        set rowNum=0,headerCount=0
        ;
        kill @("^"_gname)       ; clear existing data
        ;
        open path:(readonly:exception="goto eof")
        use path
        for  read line  quit:$zeof  do
        .  set line=$$trim^strfns(line)
        .  if line="" quit           ; skip blank lines
        .  if rowNum=0 do            ; first line = headers
        .  .  set headerCount=$$parseHeaders(line,gname)
        .  .  set rowNum=1
        .  else  do                  ; data row
        .  .  do importRow(line,rowNum,gname,headerCount)
        .  .  set rowNum=rowNum+1
eof
        close path
        use $principal
        ;
        set @("^"_gname_"(""count"")")=rowNum-1
        write "Imported ",rowNum-1," rows from ",path,!
        quit
        ;
show(gname)
        ; Print imported data as a formatted table.
        do require^safe($$exists(gname),"^"_gname_" is empty — import a file first")
        ;
        new i,n,col,val,hdr,total
        set total=$get(@("^"_gname_"(""count"")"),0)
        ;
        ; Header row
        set n=$$headerCount(gname),hdr=""
        for i=1:1:n  do
        .  set col=$get(@("^"_gname_"(""headers"","_i_")"))
        .  write $$pad^strfns(col,15),"  "
        write !
        write $translate($justify("",n*17),",","-"),!
        ;
        ; Data rows
        for i=1:1:total  do
        .  for n=1:1:$$headerCount(gname)  do
        .  .  set col=$get(@("^"_gname_"(""headers"","_n_")"))
        .  .  set val=$get(@("^"_gname_"("_i_","""_col_""")"),"")
        .  .  write $$pad^strfns(val,15),"  "
        .  write !
        quit
        ;
; ── Private ───────────────────────────────────────────────────────────────────
        ;
parseHeaders(line,gname)
        ; Parse header row and store in ^gname("headers",n). Returns field count.
        new i,n,header
        set n=$$count^strfns(line,",")
        for i=1:1:n  do
        .  set header=$$trim^strfns($$parseField(line,i))
        .  set @("^"_gname_"(""headers"","_i_")")=header
        quit n
        ;
importRow(line,rowNum,gname,headerCount)
        ; Parse one data row and store fields by header name.
        new i,header,value,ref
        for i=1:1:headerCount  do
        .  set header=$get(@("^"_gname_"(""headers"","_i_")"))
        .  set value=$$trim^strfns($$parseField(line,i))
        .  set @("^"_gname_"("_rowNum_","""_header_""")")=value
        quit
        ;
parseField(line,n)
        ; Return the nth field (1-based) from a CSV line.
        ; Handles: plain fields, "quoted,fields", "doubled ""quotes"""
        ;
        new pos,ch,field,inQuote,cur,done
        set pos=1,field="",inQuote=0,cur=1,done=0
        ;
        for pos=1:1:$length(line)  do  quit:done
        .  set ch=$extract(line,pos)
        .  if 'inQuote do
        .  .  if ch="," do  quit       ; field separator
        .  .  .  if cur=n set done=1 quit   ; end of our target field
        .  .  .  set cur=cur+1,field=""     ; advance to next field
        .  .  if ch="""" set inQuote=1 quit ; start of quoted field
        .  .  set field=field_ch             ; normal character
        .  else  do                          ; inside a quoted field
        .  .  if ch'="""" set field=field_ch quit  ; normal quoted char
        .  .  if $extract(line,pos+1)="""" do      ; doubled quote = literal "
        .  .  .  set field=field_"""",pos=pos+1
        .  .  else  set inQuote=0                   ; end of quoted field
        ;
        if cur=n quit field     ; last field (no trailing comma) or done=1
        quit ""                 ; field n beyond end of line
        ;
fieldCount(line)
        ; Count fields in a CSV line (handles quoted fields with commas).
        new pos,ch,inQuote,count
        set pos=1,inQuote=0,count=1
        for pos=1:1:$length(line)  do
        .  set ch=$extract(line,pos)
        .  if 'inQuote do
        .  .  if ch="," set count=count+1 quit
        .  .  if ch="""" set inQuote=1 quit
        .  else  do
        .  .  if ch'="""" quit
        .  .  if $extract(line,pos+1)="""" set pos=pos+1 quit  ; doubled quote
        .  .  set inQuote=0
        quit count
        ;
headerCount(gname)
        ; Return the number of headers stored for this global.
        new n,key
        set n=0,key=""
        for  set key=$order(@("^"_gname_"(""headers"","_key_")")) quit:key=""  set n=n+1
        quit n
        ;
exists(gname)
        ; Return 1 if ^gname has any data.
        quit ($data(@("^"_gname))>0)
