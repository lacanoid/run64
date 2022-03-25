
.proc TEST
  rEntry "TEST"
  rJsr HEND
  rJsr HSTART
  rJsr SUB
  rInt 2
  rJsr ADD
  rRun INC
  rRet
  next:
.endproc

.proc INC
  rEntry "INC"
  rInt 1
  rJsr ADD
  rRet
  next:
.endproc

.proc TEST2
  Entry "TEST2"
  Run TEST
  SpLoad
  Push 2
  Exec ADD
  rts
  next:
.endproc



.proc DUMP
  Entry "DUMP"
  SpLoad
  CopyTo 1, print::arg
  jsr print::dump_hex
  SpLoad
  Push 64
  Exec ADD
  rts
  next:
.endproc

.proc TDUMP
  Entry "TDUMP"
  SpLoad
  CopyTo 1, print::arg
  jsr print::dump_text
  SpLoad
  Push 256
  Exec ADD
  rts
  next:
.endproc

.proc PRINT
  Entry "PRINT"
  SpLoad
  CopyTo 1, print::arg
  jsr print::print_z
  SpLoad
  SpDec
  rts
  next:
.endproc


.proc VOCAB
  Entry "VOCAB"
  SpLoad
  PushFrom vocab::bottom
  rts
  next:
.endproc


.proc PSTART
  Entry "PSTART"
  SpLoad
  Push PROG_START
  rts
  next:
.endproc

.proc PEND
  Entry "PEND"
  SpLoad
  Push PROG_END
  rts
  next:
.endproc

.proc HSTART
  Entry "HSTART"
  SpLoad
  Push HEAP_START
  rts
  next:
.endproc


.proc HEND
  Entry "HEND"
  SpLoad
  PushFrom TOP
  rts
  next:
.endproc

.proc HSIZE
  Entry "HSIZE"
  Exec HEND
  Exec HSTART
  Exec SUB
  rts
  next:
.endproc

.proc HCLEAR
  Entry "HCLEAR"
  ISet TOP, HEAP_START
  
  rts
  next:
.endproc

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

.proc PEEK16
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

.proc POKE16
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
