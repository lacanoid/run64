DEF INC, INCR
  _ #1
  _ ADD
END

DEF TEST
  _ HEND
  _ HSTART
  _ SUB
  IF 
    _ #1
    _ ADD
  ELSE
    _ #0
    _ DUP
    _ #1
    _ ADD
    _ DEC
    IF 
    _ #2
    _ DEC 
    ENDIF
  _ #3
  _ DEC
  ENDIF
END 

DEF DUMP
_ DUP
_ #print::dump_hex
_ #print::arg
_ CALL1
_ #64
_ ADD
END

DEF TDUMP
  _ DUP
  _ #print::dump_text
  _ #print::arg
  _ CALL1
  _ #256
  _ ADD
END

DEF PRINT
  _ #print::print_z
  _ #print::arg
  _ CALL1
END

__ CALL1
  _ ROT
  _ POKE16
  _ SYS
__

__ VOCAB
  _ #vocab::bottom
  _ PEEK16
__

__ PSTART
  _ #PROG_START
__

__ PEND
  _ #PROG_END
__

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

.proc SYS
    Entry "SYS"
    SpLoad
    PopTo rewrite+1
    rewrite:
    jsr $DEF
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
