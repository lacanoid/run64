
CMD cCREATE, "CREATE"
COMPILE
  jsr compiler::skip_space
  bcc not_eof
    jmp compiler::die
  not_eof:
  WriteYB HERE_PTR, bytecode::GTO, 0 ; id, it's a regulae word
  IWriteY HERE_PTR, HERE_PTR
  
  WriteYW HERE_PTR, DEFAULT_COMPILER, vocab::compile_offset
  WriteYW HERE_PTR, DEFAULT_LISTER
  ldx #0
  loop: 
    ReadX compiler::offset
    cmp #33
    bcc break
    pha 
    PrintChr
    pla
    WriteY HERE_PTR
    bra loop
  break:
  WriteYB HERE_PTR, 0
  txa
  IAddA compiler::offset
  tya
  tax
  WriteYW HERE_PTR, cINT
  IWriteY HERE_PTR, HERE_PTR 
  WriteYW HERE_PTR, cRET
  IMov TEMP_PTR, HERE_PTR
  txa
  IAddA TEMP_PTR
  IWriteX HERE_PTR,TEMP_PTR,vocab::exec_offset
  IMov TEMP_PTR, VP
  IWriteX HERE_PTR,TEMP_PTR,vocab::next_offset
  IMov VP, HERE_PTR
  tya
  IAddA HERE_PTR
  PushFrom VP
  rts
  TEMP_PTR: .word 0
  catch:
    jmp compiler::die
END

CMD cDOES, "DOES"
rts
COMPILE
  ISubB HERE_PTR, 6
  CSet compiler::creating,$FF
  rts
END

CMD cEND, ";"
rts
COMPILE
  WriteXW HERE_PTR,cRET,0
  IAddB HERE_PTR,2
  CClear compiler::creating
  rts
END

CMD cINT, "#INT",2
  jmp runtime::doInt
COMPILE
  rts
LIST
  PeekA LP,2
  sta print::arg
  PeekA LP,3
  sta print::arg+1
  jmp print::print_dec
END

CMD cSTR, "#STR",2
  jmp runtime::doStr
COMPILE
  rts
LIST
  PrintChr '"'
  IMov print::arg, LP
  IAddB print::arg, 4
  jsr print::print_z
  PrintChr '"'
  rts
END

CMD cRET,"RET"
  ;wait:
  ;inc 53280
  ;jmp wait
  jmp runtime::doRet
END


CMD cIF,"IF",2
  jmp runtime::doIf
COMPILE
  cWriteCtl
  cWriteHope IF0
  rts
END

CMD cELSE,"ELSE",2
  jmp runtime::goto_from_ip
COMPILE
  cWriteCtl
  cResolveHope IF0, 2
  bcs catch
  cDrop
  cWriteHope IF0 
  rts
  catch:
    jmp compiler::rmismatch
END

CMD cTHEN,"THEN"
  rts
COMPILE
  cResolveHope IF0
  bcs catch
  cDrop
  cWriteCtl
  rts
  catch:
    jmp compiler::rmismatch
END


CMD cBEGIN,"BEGIN"
  rts
COMPILE
  cWriteCtl
  cStoreRef BGN
  rts
END

CMD cWHILE,"WHILE",2
  jmp runtime::doIf
COMPILE
  cWriteCtl
  cWriteHope WHL
  rts
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
  rts
  catch:
    jmp compiler::rmismatch
END

