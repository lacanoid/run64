
PROC DROP
  SpLoad
  SpDec
  rts 
END 

PROC SWAP
  SpLoad
  Copy 1,0
  Copy 2,1
  Copy 0,2
  rts
END 

PROC ROT
  SpLoad
  Copy 3,0
  Copy 2,3
  Copy 1,2
  Copy 0,1
  rts
END

PROC OVER
  SpLoad
  Copy 2,0
  SpInc
  rts 
END

PROC DUP
  SpLoad
  Copy 1,0
  SpInc
  rts 
END

PROC CLEAR
  lda #0
  sta f_SP
  rts
END

PROC CNT, "#"
  SpLoad
  PushByteFrom f_SP
  Push 2
  Run DIV
  rts
END

PROC PRINT_STACK, "??"
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
END

PROC HEX, ".$"
  SpLoad
  PrintHex
  SpDec
  rts
END

PROC DEC, "."
  SpLoad
  PrintDec
  SpDec
  PrintChr ' '
  rts
  next:   
END

PROC LOOK, "?"
  SpLoad
  PrintDec
  rts
END

PROC SYS
  SpLoad
  PopTo rewrite+1
  rewrite:
  jsr $DEF
  rts
END

PROC GET, "@"
  Stash TMP
  SpLoad
  CopyTo 1,TMP
  ldy #0
  lda (TMP),y
  SetLo 1
  iny
  lda (TMP),y
  SetHi 1
  Unstash TMP
  rts 
END

PROC SET,  "!"
  Stash TMP
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
  Unstash TMP
  rts 
END