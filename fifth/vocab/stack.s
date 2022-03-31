
PROC DROP
  
  SpDec
  rts 
END 

PROC SWAP
  
  Copy 1,0
  Copy 2,1
  Copy 0,2
  rts
END 

PROC ROT
  
  Copy 3,0
  Copy 2,3
  Copy 1,2
  Copy 0,1
  rts
END

PROC OVER
  Copy 2,0
  SpInc
  rts 
END

PROC DUP, "DUP"
  Copy 1,0
  SpInc
  rts 
END

PROC CLEAR
  lda #0
  sta f_SP
  rts
END


PROC PRINT_STACK, "??"
  ldx f_SP
  loop:
    cpx #0
    beq done 

    lda #' '
    jsr CHROUT
    
    dex
    lda STACK,x
    sta print::arg+1
    dex
    lda STACK,x
    sta print::arg
    jsr print::print_dec
    clc 
    bcc loop
  done:
    rts
END

PROC HEX, ".$"
  
  OutputHex
  SpDec
  rts
END

PROC DEC, "."
  
  OutputDec
  SpDec
  PrintChr ' '
  rts
END

PROC LOOK, "?"
  
  OutputDec
  rts
END

PROC SYS
  PopTo rewrite+1
  rewrite:
  jsr $DEF
  rts
END

PROC GET, "@"
  Stash TMP
  
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