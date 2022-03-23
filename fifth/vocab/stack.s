
.proc DROP
    Entry "DROP"
    SpDec
    rts 
    next:
.endproc

.proc SWAP
    Entry "SWAP"
    SpLoad
    Copy 1,0
    Copy 2,1
    Copy 0,2
    rts 
    next:
.endproc

.proc OVER
    Entry "OVER"
    SpLoad
    Copy 2,0
    SpInc
    rts 
    next:
.endproc

.proc DUP
    Entry "DUP"
    SpLoad
    Copy 1,0
    SpInc
    rts 
    next:
.endproc

.proc CLEAR
    Entry "CLEAR"
    lda #0
    sta SP
    rts
    next:
.endproc



.proc _COUNT
    Entry "COUNT"
    SpLoad
    PushByteFrom SP
    rts
    next:
.endproc

.proc PRINT_STACK
    Entry "??"
    PrintChr '#'
    
    ldx SP 
    loop:
        cpx #1
        bcc done 

        lda #' '
        jsr CHROUT
        
        PrintDec
        
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
    Entry ".$"
    SpLoad
    jsr print_hex 
    jsr DROP
    rts
    next:
.endproc

.proc DEC
    Entry "."
    SpLoad
    PrintDec
    SpDec
    PrintChr ' '
    rts
    next:     
.endproc 

.proc LOOK
    Entry "?"
    SpLoad
    jsr print_dec
    rts
    next=0     
.endproc 
