.scope dos 
  .proc ls
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
      DEY
      BNE skip2

      JSR getbyte    ; get low byte of basic line number
      sta print::arg
      JSR getbyte    ; get high byte of basic line number
      sta print::arg+1
      jsr print::print_dec
      LDA #$20       ; print a space first
    char:
      JSR $FFD2      ; call CHROUT (print character)
      JSR getbyte
      BNE char      ; continue until end of line

      LDA #$0D
      JSR $FFD2      ; print RETURN
      JSR $FFE1      ; RUN/STOP pressed?
      BNE next      ; no RUN/STOP -> continue
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