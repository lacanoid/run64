DEF ONE, "ONE"
  _ #1
END

DEF TWO, "TWO"
  _ DUP
  _ MUL
END

DEF THREE, "THREE"
  _ ADD
  _ TWO 
  _ DIV
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
  AGAIN
END 

DEF DUMP
_ DUP
_ #print::dump_hex
_ #print::arg
_ CALL1
_ #64
_ ADD
END

DEF IDUMP
_ DUP
_ #debug::idump
_ #print::arg
_ CALL1
_ #print::arg
_ GET
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
  NEXT
END

DEF PRINT
  _ #print::print_z
  _ #print::arg
  _ CALL1
END

DEF CALL1
  _ ROT, SWAP, SET
  _ SYS
END

DEF LATEST
  _ #VP
  _ GET
END

DEF PSTART
  _ #PROG_START
END

DEF PEND
  _ #PROG_END
END 

DEF HERE
  _ #HERE_PTR
  _ GET
END

PROC POKE
  CopyTo 2,TMP
  GetLo 1
  SpDec
  SpDec
  ldx #0
  sta (TMP,x)
  NEXT 
END

PROC PEEK
  Stash TMP
  
  CopyTo 1,TMP
  ldy #0
  lda (TMP),y
  InsertA 1
  Unstash TMP
  NEXT 
END
