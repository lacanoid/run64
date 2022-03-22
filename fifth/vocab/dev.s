
.proc VLIST
    entry "VLIST"
    jsr reset_cursor
    
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
        jsr advance_cursor
        bne print_entry
    
    rts
    next:
.endproc

.proc WHITE
    entry "WHITE"
    jsr INK
    PUSH $1
    jsr POKE
    rts
    next:
.endproc

.proc INK
    entry "INK"
    PUSH $286
    rts
    next:
.endproc

.proc POKE
    entry "POKE"
    ldx SP
    lda STACK-4,x
    sta TMP
    lda STACK-3,x
    sta TMP+1 
    lda STACK-2,x
    ldy #0
    sta (TMP),y
    dex
    dex
    dex
    dex
    stx SP
    rts
    next:
.endproc

.proc PEEK
    entry "PEEK"
    ldx SP
    lda STACK-2,x
    sta TMP
    lda STACK-1,x
    sta TMP+1
    lda #0
    tay
    sta STACK-1,x
    lda (TMP),y
    sta STACK-2,x
    rts
    next:
.endproc

.proc QUIT
    entry "QUIT"
    inc f_quit
    rts
    next:
.endproc
