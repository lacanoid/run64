.feature c_comments

jmp MAIN
.include "ilib/core.s"
.include "ilib/idump.s"
MAIN = imenu::main

MenuRoot "Home"
  MenuHeading "This is the root menu 1"
  MenuHeading "This is the root menu 2"
  MenuHeading "This is the root menu 3"
  MenuHeading "This is the root menu 4"
  MenuHeading "This is the root menu 1"
  MenuHeading "This is the root menu 4"
  MenuHeading "This is the root menu 1"
  MenuHeading "This is the root menu 2"
  MenuHeading "This is the root menu 3"
  MenuHeading "This is the root menu 4"
  MenuAction "dump items"
    ISet idump::HOME, imenu::MENU_ITEMS
    jmp idump::main
  MenuAction "dump heap"
    ISet idump::HOME, $C000
    jmp idump::main
  MenuAction "idump"
    jmp idump::main
  MenuDirectory "ls"
  MenuSub "Border"
    MenuAction "white"
      lda #1
      sta 53280
      rts
    MenuAction "red"
      lda #2
      sta 53280
      rts 
    MenuAction "blue"
      lda #3
      sta 53280
      rts
    MenuBackLink
  EndMenuSub 
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
EndMenu
