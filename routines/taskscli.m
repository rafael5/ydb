taskscli        ; CLI entry point for the tasks module.
        ; Called by bin/tasks — never run directly.
        ;
        ; $ZCMDLINE format: "subcmd|arg"
        ; The | separator lets multi-word task titles survive intact.
        ;
        new cmd,arg,ok,err
        set cmd=$piece($zcmdline,"|",1)
        set arg=$piece($zcmdline,"|",2,999)  ; everything after first |
        ;
        if cmd="add"        do addCmd(arg)      quit
        if cmd="list"       do list^tasks()     quit
        if cmd="done"       do doneCmd(arg)     quit
        if cmd="undone"     do undoneCmd(arg)   quit
        if cmd="del"        do delCmd(arg)      quit
        if cmd="show"       do show^tasks()     quit
        if cmd="clear-done" do clearDoneCmd()   quit
        ;
        do usage
        quit
        ;
addCmd(title)
        if title="" do usage  quit
        new id
        set id=$$add^tasks(title)
        write "Added #",id,": ",title,!
        quit
        ;
doneCmd(id)
        if id="" do usage  quit
        new ok,err
        do tryCatch^safe("do done^tasks("_id_")",.ok,.err)
        if ok  write "Task #",id," done.",!
        else   write "Error: ",$$lastError^safe(),!
        quit
        ;
undoneCmd(id)
        if id="" do usage  quit
        new ok,err
        do tryCatch^safe("do undone^tasks("_id_")",.ok,.err)
        if ok  write "Task #",id," reopened.",!
        else   write "Error: ",$$lastError^safe(),!
        quit
        ;
delCmd(id)
        if id="" do usage  quit
        new ok,err
        do tryCatch^safe("do del^tasks("_id_")",.ok,.err)
        if ok  write "Task #",id," deleted.",!
        else   write "Error: ",$$lastError^safe(),!
        quit
        ;
clearDoneCmd()
        new count
        set count=$$clearDone^tasks()
        write count," completed task(s) deleted.",!
        quit
        ;
usage
        write "Usage: tasks <command> [args]",!
        write !
        write "  add <title>     Add a new task",!
        write "  list            List all tasks",!
        write "  done <id>       Mark task complete",!
        write "  undone <id>     Reopen a task",!
        write "  del <id>        Delete a task",!
        write "  show            Show raw ^tasks global",!
        write "  clear-done      Delete all completed tasks",!
        quit
