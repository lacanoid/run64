.include "dev.s"
.include "math.s"
.include "stack.s"

.proc QUIT
    Entry "QUIT"
    inc f_quit
    rts 
    next:
.endproc

.proc VLIST
    Entry "VLIST"
    jsr vocab::reset_cursor
    
    print_entry:
        ldy #5
        print_char:
            lda (vocab::cursor),y
            jsr CHROUT
            cmp #33
            bcc chars_done
            iny 
            bne print_char
        chars_done:
        PrintChr ' '
        jsr vocab::advance_cursor
        bne print_entry
    NewLine
    rts

    next=0
.endproc
