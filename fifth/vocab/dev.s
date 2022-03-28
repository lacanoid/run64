
DEF TS2
  _ #3
END

DEF TS1
  _ #1
  _ TS2
  _ PRINT
END


DEF HDUMP
  _ HSTART
  _ DUMP
  _ DROP
END

DEF INCR, "INC"
  _ #1
  _ ADD
END

DEF TEST
  _ "COUNTDOWN"
  _ PRINT
  _ #10
  BEGIN
    _ DUP
    _ DEC
    _ #1
    _ SUB
    _ DUP
  WHILE
  REPEAT
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

PROC CR
  NewLine
  rts
END

DEF PRINT
  _ #print::print_z
  _ #print::arg
  _ CALL1
END

DEF CALL1
  _ ROT
  _ SET
  _ SYS
END

DEF VOCAB
  _ #vocab::bottom
  _ GET
END

DEF PSTART
  _ #PROG_START
END

DEF PEND
  _ #PROG_END
END 


DEF HSTART
  _ #HEAP_START
END

DEF HEND
  _ #HEAP_END
  _ GET
END

DEF HSIZE
  _ HEND
  _ HSTART
  _ SUB
END

DEF HCLEAR
  _ HEND
  _ HSTART
  _ SET
END 

PROC POKE
  
  CopyTo 2,TMP
  GetLo 1
  SpDec
  SpDec
  ldx #0
  sta (TMP,x)
  rts 
END

PROC PEEK
  Stash TMP
  
  CopyTo 1,TMP
  ldy #0
  lda (TMP),y
  InsertA 1
  Unstash TMP
  rts 
END
