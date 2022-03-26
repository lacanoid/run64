
.proc DROP
    Entry "DROP"
    SpLoad
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

.proc ROT
    Entry "ROT"
    SpLoad
    Copy 3,0
    Copy 2,3
    Copy 1,2
    Copy 0,1
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
    sta f_SP
    rts
    next:
.endproc



.proc _COUNT
    Entry "COUNT"
    SpLoad
    PushByteFrom f_SP
    rts
    next:
.endproc


.proc PRINT_STACK
    Entry "??"
    
    ldx #0
    loop:
        cpx f_SP
        bcs done 

        lda #' '
        jsr CHROUT
        
        inx
        inx
        PrintDec
        
        clc 
        bcc loop

    done:
        rts
    next:
.endproc


.proc HEX
    Entry ".$"
    SpLoad
    PrintHex
    SpDec
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
    PrintDec
    rts
    next:  
.endproc 

.proc SYS
    Entry "SYS"
    SpLoad
    PopTo rewrite+1
    rewrite:
    jsr $DEF
    rts
    next:
.endproc

.proc GET
    Entry "@"
    SpLoad
    CopyTo 1,TMP
    ldy #0
    lda (TMP),y
    SetLo 1
    iny
    lda (TMP),y
    SetHi 1
    rts 
    next:
.endproc

.proc SET
  Entry "!"
  SpLoad
  CopyTo 2,TMP
  GetLo 1
  ldy #0
  sta (TMP),y
  iny
  GetHi 1
  sta (TMP),y
  SpDec
  SpDec
  
  rts 
  next:
.endproc
