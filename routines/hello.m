hello   ; Hello World — first MUMPS routine
        ;
        ; MUMPS syntax notes:
        ;   - Labels start in column 1, no indent
        ;   - Code is indented with a single space (or tab)
        ;   - Semicolons start comments
        ;   - ! means newline in WRITE
        ;   - quit ends a routine or returns from a function
        ;
        write "Hello, World!",!
        quit
        ;
greet(name)     ; Greet by name — called as: $$greet^hello("Alice")
        ; $$ means "call as a function and return its value"
        quit "Hello, "_name_"!"
        ;
shout(name)     ; Shout a greeting — demonstrates string concatenation
        quit "HELLO, "_$ZCONVERT(name,"U")_"!"
