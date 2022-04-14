.feature c_comments

jmp MAIN
.include "ilib/imenu.s"
.include "ilib/idump.s"
MAIN = imenu::main

MenuRoot "Home"
  MenuSub "disks"
    MenuDirectory "ls", 
    MenuDirectory "ls", 9
    MenuDirectory "ls", 10
    MenuDirectory "ls", 11
  EndMenuSub
  MenuSub "memory"
    MenuAction "dump heap"
      IMov idump::HOME, imenu::THERE
      jmp idump::main
    MenuAction "idump"
      jmp idump::main
  EndMenuSub 
  MenuSub "colors"
    MenuAction "default"
      CSet imenu::COLOR_BG ,imenu::DEF_BG 
      CSet imenu::COLOR_BRD,imenu::DEF_BRD
      CSet imenu::COLOR_FG ,imenu::DEF_FG 
      CSet imenu::COLOR_SEL,imenu::DEF_SEL
      CSet imenu::COLOR_HDR,imenu::DEF_HDR
      rts
    MenuAction "dark"
      CSet imenu::COLOR_BG ,0
      CSet imenu::COLOR_BRD,0
      CSet imenu::COLOR_FG ,12 
      CSet imenu::COLOR_SEL,15
      CSet imenu::COLOR_HDR,1
      rts 
    ; MenuBackLink
  EndMenuSub 
  /*
    MenuAction "read dir"
      LDA #end_dirname-dirname
      LDX #<dirname
      LDY #>dirname

      JSR $FFBD      ; call SETNAM
      LDA #$02       ; filenumber 2
      LDX $BA
      BNE skip
      LDX #$08       ; default to device number 8
    skip:
      LDY #$02       ; secondary address 0 (required for dir reading!)
      JSR $FFBA      ; call SETLFS

      JSR $FFC0      ; call OPEN (open the directory)
      bcs error

      LDX #$02       ; filenumber 2
      JSR $FFC6      ; call CHKIN

      ISet ptr, $8000

      read:
        JSR getbyte
        WriteA ptr
      bra read
      
    error:
      ; Akkumulator contains BASIC error code

      ; most likely error:
      ; A = $05 (DEVICE NOT PRESENT)
    exit:
      LDA #$02       ; filenumber 2
      JSR $FFC3      ; call CLOSE
      JSR $FFCC     ; call CLRCHN
      RTS

    getbyte:
      JSR $FFB7      ; call READST (read status byte)
      BNE end       ; read error or end of file
      JMP $FFCF      ; call CHRIN (read byte from directory)
      RTS
    end:
      PLA            ; don't return to dir reading loop
      PLA
      JMP exit
    ptr: .word 0
    dirname:  .byte "$"      ; filename used to access directory
    end_dirname:
  */
EndMenu

