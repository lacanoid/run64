
.proc WHITE
    Entry "WHITE"
    Exec INK
    SpLoad
    Push $1
    Exec POKE
    rts
    next:
.endproc

.proc INK
  Entry "INK"
  SpLoad
  Push $286
  rts 
  next:
.endproc

.proc POKE
  Entry "POKE"
  SpLoad
  CopyTo 2,TMP
  GetLo 1
  
  ldy #0
  sta (TMP),y

  SpDec
  SpDec
  
  rts 
  next:
.endproc

.proc PEEK
    Entry "PEEK"
    SpLoad
    CopyTo 1,TMP
    ldy #0
    lda (TMP),y
    InsertA 1
    rts 
    next:
.endproc
