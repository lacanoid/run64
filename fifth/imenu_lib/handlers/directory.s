MenuHandler HNDL_DIRECTORY
  ACTION:
    jmp go_to_here
  ITEMS:
    IMov HERE, HEAP
    jsr here_deref
      LDA #dirname_end-dirname
      LDX #<dirname
      LDY #>dirname
      JSR $FFBD      ; call SETNAM

      LDA #$02       ; filenumber 2
      LDX $BA
      BNE skip
      LDX #$08       ; default to device number 8
    skip:
      LDY #$00       ; secondary address 0 (required for dir reading!)
      JSR $FFBA      ; call SETLFS

      JSR $FFC0      ; call OPEN (open the directory)
      BCS error     ; quit if OPEN failed

      LDX #$02       ; filenumber 2
      JSR $FFC6      ; call CHKIN

      LDY #$04       ; skip 4 bytes on the first dir line
      BNE skip2
    next:
      LDY #$02       ; skip 2 bytes on all other lines
    skip2:
      JSR getbyte    ; get a byte from dir and ignore it
      sty rw+1
      IMov THE_ITEM,HERE
      lda $#<HNDL_HEADING
      jsr here_write_byte
      lda $#>HNDL_HEADING
      jsr here_write_byte
      

      sta print::arg 
      lda #0
      sta print::arg+0
      jsr print::number
      jsr print::space

      rw: ldy #$ff
      DEY
      BNE skip2

      JSR getbyte    ; get low byte of basic line number
      sta print::arg
      JSR getbyte    ; get high byte of basic line number
      sta print::arg+1
      jsr print::number
      LDA #$20       ; print a space first
    char:
      JSR print::char       ; call CHROUT (print character)
      JSR getbyte
      bne char      ; continue until end of line

      JSR print::nl      ; print RETURN
      bra next      ; no RUN/STOP -> continue
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
    end:
      PLA            ; don't return to dir reading loop
      PLA
      JMP exit

    dirname:  .byte "$"      ; filename used to access directory
    dirname_end:
  .endproc
.endscope

  .data   
    tmp: .word 0 
  .code 
EndMenuHandler

MenuHandler HNDL_LINK
  ACTION:
    jsr here_deref 
    ;jsr here_read_item
    jmp go_to_here
EndMenuHandler


.macro MenuLink title, id
  MenuItem HNDL_LINK, title
  .addr id
.endmacro



MenuHandler HNDL_BACK_LINK
  ACTION:
    jmp go_back 
EndMenuHandler


.macro MenuBackLink title
  .ifnblank title
    MenuItem HNDL_BACK_LINK, title
  .else
    MenuItem HNDL_BACK_LINK, "Go Back "
  .endif
.endmacro

.proc print_z_title
  jsr here_set_to_the_item
  lda #2
  jsr here_advance_a
  jsr here_deref
  jmp print_z_from_here
  rts
.endproc