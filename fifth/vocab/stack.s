
.proc DROP
    entry "DROP"
    SP_DEC
    rts
    next:
.endproc

.proc SWAP
    entry "SWAP"
    SP_LOAD
    COPY 1,0
    COPY 2,1
    COPY 0,2
    rts
    next:
.endproc

.proc OVER
    entry "OVER"
    SP_LOAD
    COPY 2,0
    SP_INC
    rts
    next:
.endproc

.proc DUP
    entry "DUP"
    SP_LOAD
    COPY 1,0
    SP_INC
    rts
    next:
.endproc

.proc CLEAR
    entry "CLEAR"
    lda #0
    sta SP
    rts
    next:
.endproc



.proc _COUNT
    entry "COUNT"
    SP_LOAD
    PUSH_BYTE_FROM SP
    rts
    next:
.endproc

.proc PRINT_STACK
    entry "??"
    PrintChr '#'
    
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
    SP_LOAD
    jsr print_hex 
    jsr DROP
    rts
    next:
.endproc

.proc DEC
    entry "."
    SP_LOAD 
    jsr print_dec
    jsr DROP
    PrintChr ' '
    rts
    next:     
.endproc 

.proc LOOK
    entry "?"
    SP_LOAD
    jsr print_dec
    rts
    next=0     
.endproc 
