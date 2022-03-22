
.proc VLIST
    entry "VLIST"
    jsr vocab__reset_cursor
    
    print_entry:
        ldy #5
        print_char:
            lda (cursor),y
            jsr CHROUT
            cmp #33
            bcc chars_done
            iny 
            bne print_char
        chars_done:
        jsr CRLF
        jsr vocab__advance_cursor
        bne print_entry
    
    rts
    next:
.endproc

.proc WHITE
    entry "WHITE"
    jsr INK
    SP_LOAD
    PUSH $1
    jsr POKE
    rts
    next:
.endproc

.proc INK
    entry "INK"
    SP_LOAD
    PUSH $286
    rts
    next:
.endproc

.proc POKE
    entry "POKE"
    SP_LOAD
    COPY_TO 2,TMP
    GET_LO 1
    
    ldy #0
    sta (TMP),y

    SP_DEC
    SP_DEC
    ;PUSH_FROM TMP
    ;PUSH_A
    rts
    next:
.endproc

.proc PEEK
    entry "PEEK"
    SP_LOAD
    COPY_TO 1,TMP
    ldy #0
    lda (TMP),y
    INSERT_A 1
    rts
    next:
.endproc

.proc QUIT
    entry "QUIT"
    inc f_quit
    rts
    next:
.endproc
