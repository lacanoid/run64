PROC cQUOT, "", '"'
  PushFrom HEAP_END 
  loop:
    lda eof
    bne catch
    jsr read_char
    cmp #'"'
    beq break
    WriteA HEAP_END
  bra loop
  break:
  lda #0
  WriteA HEAP_END
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
  ReadA compiler::POS
  PushA
  NEXT
END

PROC WORD
  PrintString "WORD"
  jsr compiler::skip_space
  PushFrom compiler::POS
  bcc not_eof
    cError "EOF"
  not_eof:
  ldx #0
  loop: 
    ReadX compiler::POS
    pha
    PrintChr
    pla
    cmp #33
    bcc break
    bra loop
  break:
  dex
  AdvanceX compiler::POS
  txa
  PushA
  NEXT
END

CMD cCREATE, "CREATE"
  jsr mode_compile
  PrintString "CREATING"
  jsr compiler::skip_space
  bcc not_eof
    cError "EOF"
  not_eof:
  WriteYB HERE, bytecode::NAT, 0
  IWriteY HERE, HERE
  
  WriteYW HERE, DEFAULT_COMPILER, vocab::compile_offset
  WriteYW HERE, DEFAULT_LISTER
  ldx #0
  loop: 
    ReadX compiler::POS
    cmp #33
    bcc break
    WriteY HERE
    bra loop
  break:
  WriteYB HERE, 0
  AdvanceX compiler::POS
  jsr compiler::advance_offset
  tya
  tax
  WriteYB HERE, DOCOL0
  WriteYB HERE, DOCOL1
  WriteYB HERE, DOCOL2
  WriteYW HERE, cINT
  IWriteY HERE, HERE 
  WriteYW HERE, cRET
  IMov TEMP_PTR, HERE
  txa
  IAddA TEMP_PTR
  IWriteX HERE,TEMP_PTR,vocab::exec_offset
  IMov TEMP_PTR, VP
  IWriteX HERE,TEMP_PTR,vocab::next_offset
  IMov VP, HERE
  tya
  IAddA HERE
  PushFrom VP
  PrintString "CREATED"
  jsr mode_compile
  NEXT
  TEMP_PTR: .word 0
END

CMD cSEMI, ";"
  cError "ONLY IN COMPILER MODE"
  NEXT
COMPILE
  PrintString "SHOULD BE DONE"
  WriteXW HERE,cRET,0
  IAddB HERE,2
  CClear compiler::creating
  NEXT
END


CMD cDOES, "DOES"
  NEXT
COMPILE
  NEXT
END

CMD POSTPONE, "POSTPONE",2
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

CMD cSTR, "#STR",2
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

CMD cRET,"RET"
  NEXT
END


CMD cIF,"IF",2
  jmp runtime::doIf
COMPILE
  cWriteCtl
  cWriteHope IF0
  NEXT
END

CMD cELSE,"ELSE",2
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

CMD cTHEN,"THEN"
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


CMD cBEGIN,"BEGIN"
  NEXT
COMPILE
  cWriteCtl
  cStoreRef BGN
  NEXT
END

CMD cWHILE,"WHILE",2
  jmp runtime::doIf
COMPILE
  cWriteCtl
  cWriteHope WHL
  NEXT
END

CMD cAGAIN,"AGAIN",2
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

