server ; Minimal HTTP/1.0 JSON server — serves YottaDB data over TCP.
       ; Entry point: called by bin/yserve via do start^server(port)
       quit
       ;
; start(port) — bind port and serve requests forever (Ctrl-C to stop)
start(port)
       set port=$get(port,8080)
       write "Starting server on http://localhost:",port," (Ctrl-C to stop)",!
       do log^trace("server","Starting on port "_port)
       for  do serveOne(port)
       quit
       ;
; serveOne(port) — open socket, accept one connection, respond, close
; Uses the open-per-request pattern: YottaDB sets SO_REUSEADDR automatically,
; so rebinding the same port on each iteration is safe.
serveOne(port)
       new dev,line,method,path,hdr,resp,status
       set dev="|TCP|"_port_"|"_$job
       ; ZLISTEN binds the port; NODELIMITER for raw byte control;
       ; ATTACH="listener" names the socket for the /WAIT call.
       open dev:(zlisten=port_":TCP":nodelimiter:attach="listener"):5:"SOCKET"
       if '$test  write "ERROR: cannot bind port ",port,!  quit
       use dev
       write /listen(1)
       ; Wait for an incoming connection.
       ; After /WAIT, the accepted socket becomes current in the device.
       use dev:(socket="listener")
       for  write /wait  quit:$key]""
       ; Set newline delimiter on the accepted connection for line-by-line header reads
       use dev:(delim=$char(10))
       ; Read HTTP request line
       set line=""
       read line:5
       if line=""  close dev  quit
       ; Strip trailing CR (HTTP uses CRLF line endings)
       if $extract(line,$length(line))=$char(13) do
       .  set line=$extract(line,1,$length(line)-1)
       set method=$piece(line," ",1)
       set path=$piece(line," ",2)
       ; Strip query string
       if $find(path,"?")>1  set path=$piece(path,"?",1)
       do log^trace("server",method_" "_path)
       ; Drain remaining request headers (read until blank line)
       for  set hdr=""  read hdr:2  quit:(hdr="")!($extract(hdr,1)=$char(13))
       ; Dispatch to route handler
       set status="200 OK"
       set resp=$$dispatch(method,path,.status)
       ; Switch to no-delimiter mode for exact HTTP response output
       use dev:(nodelimiter)
       write "HTTP/1.0 ",status,$char(13,10)
       write "Content-Type: application/json",$char(13,10)
       write "Access-Control-Allow-Origin: *",$char(13,10)
       write $char(13,10)
       write resp
       close dev
       quit
       ;
dispatch(method,path,status)
       if path="/"         quit $$rootInfo()
       if path="/tasks"    quit $$listTasks()
       if $extract(path,1,7)="/tasks/"  quit $$taskRoute($extract(path,8,99),.status)
       set status="404 Not Found"
       quit $$err("Not found: "_path)
       ;
; ── Route handlers ────────────────────────────────────────────────────────────
       ;
rootInfo()
       new keys,vals
       set keys(1)="name",vals(1)=$$str^json("YottaDB REST server")
       set keys(2)="routes",vals(2)=$$routes()
       quit $$obj^json(.keys,.vals)
       ;
routes()
       new items
       set items(1)=$$str^json("GET /")
       set items(2)=$$str^json("GET /tasks")
       set items(3)=$$str^json("GET /tasks/:id")
       quit $$arr^json(.items)
       ;
listTasks()
       new id,items,n
       set id="",n=0
       for  set id=$order(^tasks(id))  quit:id=""  do
       .  set n=n+1
       .  set items(n)=$$taskJson(id)
       quit $$arr^json(.items)
       ;
taskRoute(id,status)
       if id=""!'$data(^tasks(+id))  set status="404 Not Found"  quit $$err("Task not found: "_id)
       quit $$taskJson(+id)
       ;
taskJson(id)
       new keys,vals
       set keys(1)="id",vals(1)=$$num^json(id)
       set keys(2)="title",vals(2)=$$str^json($get(^tasks(id)))
       set keys(3)="done",vals(3)=$$bool^json($get(^tasks(id,"done"),0))
       set keys(4)="created",vals(4)=$$str^json($get(^tasks(id,"created")))
       quit $$obj^json(.keys,.vals)
       ;
err(msg)
       new keys,vals
       set keys(1)="error",vals(1)=$$str^json(msg)
       quit $$obj^json(.keys,.vals)
