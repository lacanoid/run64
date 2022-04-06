PROC cQUOT, "", '"'
  PushFrom HEAP_END 
  loop:
    lda eof
    bne catch
    jsr read_char
    cmp #'"'
    beq break
    jsr heap::write
  bra loop
  break:
  jsr heap::write_zero
  NEXT
  catch:
    ThrowError "UNCLOSED STRING"
END 

PROC EXIT
  RPop
  NEXT
END

PROC KEY
  SpInc
  jsr read_char
  PushA
  NEXT
END

DEF FINDWORD, "'"
  _ WORD, FIND
END


PROC FIND
  PopTo vocab::arg
  jsr vocab::find_entry
  bcs not_found
    PushFrom vocab::cursor
    NEXT
  not_found:
  lda #0
  PushA
  NEXT
END

PROC WORD
  PushFrom HEAP_END 
  ldy #0
  loop:
    lda eof
    bne catch
    jsr read_char
    cmp #33
    bcc break
    jsr heap::write
    iny
  bra loop
  break:
  tya
  ;PushA
  jsr heap::write_zero
  NEXT
  catch:
    ThrowError "UNCLOSED STRING"
END 

PROC COMMA, ","
  GetLo 1
  jsr here::write 
  GetHi 1
  jsr here::write 
  SpDec 
  NEXT
END

PROC SCOMMA, "S,"
  PopTo here::arg
  jsr here::write_string
  NEXT
END


PROC CCOMMA, "C,"
  GetLo 1
  jsr here::write 
  SpDec 
  NEXT
END

DEF CREATE, "CREATE"
  _ WORD
  _ CREAT
END

PROC CREAT, "CREAT"
  DOCOL
  _ HERE
    _ #bytecode::NAT, CCOMMA 
    _ HERE
      _ #$DEFD, COMMA
      _ #0, CCOMMA
      _ LATEST, COMMA
      _ ROT, SCOMMA
    _ HERE, SWAP, SET
    _ #$20, CCOMMA
    _ #DO_DOCOL, COMMA
    _ #cINT, COMMA
    _ HERE, #6, ADD, COMMA
    _ #EXIT, COMMA
    _ #0, COMMA
    _ DONE
    PopTo VP 
  NEXT
END

DEF DOES, "DOES>"
  _ LATEST, JMP
  _ #4, SUB
  _ DUP, #BRANCH, SWAP, SET
  _ #2, ADD
  _ HERE, SWAP, SET
  _ STATE1
END

PROC BRANCH, "BRANCH"
  PushFrom IP
  PopTo IP
  NEXT
END

IDEF SEMICOLON, ";"
  _ #EXIT, COMMA
  _ STATE0
END

IDEF COLON, ":"
  _ CREATE
  _ DOES 
  _ DROP
END

IPROC STATE0, "]"
  CClear STATE
  NEXT
END

IPROC STATE1, "["
  CSet STATE, 1
  NEXT
END


PROC RESET
  ISet HERE_PTR, PROG_END
  ISet VP, VOCAB_START
  NEXT
END

PROC JMP
  PopTo entry
  DOCOL
    entry: .word 0
  _ EXIT 
END


IPROC cSEMI, ";"
  cError "ONLY IN COMPILER MODE"
  NEXT
COMPILE
  PrintString "SHOULD BE DONE"
  WriteXW HERE_PTR,cRET,0
  IAddB HERE_PTR,2
  CClear compiler::creating
  NEXT
END


IPROC POSTPONE, "POSTPONE",2
COMPILE
  jsr compiler::skip_space
  bcs catch 
  
  IMov vocab::arg, compiler::POS
  jsr vocab::find_entry
  bcs catch
  IAddA compiler::POS
  
  IMov compiler::result, vocab::cursor
  jmp compiler::write_result
  NEXT
  catch:
    cError "NOT FOUND"
END



PROC cINT, "#INT",2
    SpInc
    ReadA IP
    SetLo 1
    ReadA IP
    SetHi 1
    NEXT
/*COMPILE
  NEXT
LIST
  PeekA LP,2
  sta print::arg
  PeekA LP,3
  sta print::arg+1
  jmp print::print_dec
*/
END

IPROC cSTR, "#STR",2
  jmp runtime::doStr
COMPILE
  NEXT
LIST
  PrintChr '"'
  IMov print::arg, LP
  IAddB print::arg, 4
  jsr print::print_z
  PrintChr '"'
  NEXT
END

IPROC cRET,"RET"
  NEXT
END


IPROC cIF,"IF",2
  jmp runtime::doIf
COMPILE
  cWriteCtl
  cWriteHope IF0
  NEXT
END

IPROC cELSE,"ELSE",2
  jmp runtime::goto_from_ip
COMPILE
  cWriteCtl
  cResolveHope IF0, 2
  bcs catch
  cDrop
  cWriteHope IF0 
  NEXT
  catch:
    jmp compiler::rmismatch
END

IPROC cTHEN,"THEN"
  NEXT
COMPILE
  cResolveHope IF0
  bcs catch
  cDrop
  cWriteCtl
  NEXT
  catch:
    jmp compiler::rmismatch
END


IPROC cBEGIN,"BEGIN"
  NEXT
COMPILE
  cWriteCtl
  cStoreRef BGN
  NEXT
END

IPROC cWHILE,"WHILE",2
  jmp runtime::doIf
COMPILE
  cWriteCtl
  cWriteHope WHL
  NEXT
END

IPROC cAGAIN,"AGAIN",2
  jmp runtime::goto_from_ip
COMPILE
  cWriteCtl
  loop:
    cResolveHope WHL,2
    bcs break
    cDrop
  bra loop
  break:
    
  cWriteRef BGN
  bcs catch
  cDrop
  NEXT
  catch:
    jmp compiler::rmismatch
END

