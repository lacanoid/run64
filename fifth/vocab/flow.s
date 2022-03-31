CMD cINT, "#RES",2
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

CMD cSTR, "#RES",2
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

