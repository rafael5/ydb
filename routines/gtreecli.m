gtreecli        ; CLI entry point for gtree.
        ; Called by bin/gtree — never run directly.
        ; $ZCMDLINE = globalname (with or without leading ^)
        ;
        if $zcmdline="" do usage  quit
        do show^gtree($zcmdline)
        quit
        ;
usage
        write "Usage: gtree <globalname>",!
        write !
        write "  gtree contacts",!
        write "  gtree tasks",!
        write "  gtree people",!
        write "  gtree ^tasks     (leading ^ accepted)",!
        quit
