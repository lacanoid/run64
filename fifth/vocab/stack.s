.proc DROP
    entry "DROP"
    ldx SP
    dex
    dex 
    stx SP
    rts
    next:
.endproc


.proc DUP
    entry "DUP"
    ldx SP
    lda STACK-2,x
    sta STACK,x
    inx 
    lda STACK-2,x
    sta STACK,x
    inx 
    stx SP
    rts
    next:
.endproc

.proc _SP
    entry "SP"
    lda SP
    jsr WRTWO
    rts
    next:
.endproc

.proc _STACK
    entry ".S"
    lda #'('
    jsr CHROUT
    lda SP
    lsr
    jsr WRTWO 
    lda #')'
    jsr CHROUT

    ldx SP 
    loop:
        cpx #1
        bcc done 

        lda #' '
        jsr CHROUT
        
        jsr print_dec
        dex
        dex
        clc 
        bcc loop

    done:
        jsr CRLF
        rts
    next:
.endproc


.proc HEX
    entry ".$"

    lda #'$'
    jsr CHROUT
    ldx SP
    dex
    lda STACK,x
    jsr WRTWO
    dex
    lda STACK,x
    jsr WRTWO
    stx SP
    rts
    next:
.endproc

.proc DEC
    entry "."
    ldx SP 
    jsr print_dec
    dex
    dex
    stx SP
    rts
    next:     
.endproc 

.proc LOOK
    entry "?"
    ldx SP 
    jsr print_dec
    rts
    next=0     
.endproc 
