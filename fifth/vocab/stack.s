
PROC DROP
  SpDec
  NEXT 
END 

PROC SWAP
  
  Copy 1,0
  Copy 2,1
  Copy 0,2
  NEXT
END 

PROC ROT
  
  Copy 3,0
  Copy 2,3
  Copy 1,2
  Copy 0,1
  NEXT
END

PROC OVER
  Copy 2,0
  SpInc
  NEXT
END

PROC DUP, "DUP"
  Copy 1,0
  SpInc
  NEXT
END

PROC CLEAR
  lda #0
  sta f_SP
  NEXT
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
    NEXT
END

PROC HEX, ".$"
  
  OutputHex
  SpDec
  NEXT
END

PROC DEC, "."
  
  OutputDec
  SpDec
  PrintChr ' '
  NEXT
END

PROC LOOK, "?"
  
  OutputDec
  NEXT
END

PROC SYS
  PopTo rewrite+1
  rewrite:
  jsr $DEF
  NEXT
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
  NEXT 
END

PROC SET,  "!"
  Stash TMP
  
  PopTo TMP
  GetLo 1
  ldy #0
  sta (TMP),y
  iny
  GetHi 1
  sta (TMP),y
  SpDec
  Unstash TMP
  NEXT 
END