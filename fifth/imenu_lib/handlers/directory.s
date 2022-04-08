MenuHandler HNDL_DIRECTORY
  ACTION:
    jmp go_to_the_item
  ITEMS:
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
    BCC ok
    jmp error     ; quit if OPEN failed
    ok:

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
  
    jsr add_item_there
    lda #<HNDL_FILE
    jsr there_write_byte
    lda #>HNDL_FILE
    jsr there_write_byte

    lda #0
    jsr there_write_byte
    ldy #0
    JSR getbyte    ; get low byte of basic line number
    sta tmp
    JSR getbyte    ; get high byte of basic line number
    sta tmp+1
    
    skip3:
      jsr getbyte
      cmp #'"'
    bne skip3

  char:
    JSR getbyte
    beq break
    cmp #'"'
    beq break
    iny
    JSR there_write_byte
    clc
    bcc char
  break:
    ; write terminator and length
    lda #0
    jsr there_write_byte

    ; write file length that we stored earlier
    lda tmp
    jsr there_write_byte
    lda tmp+1
    jsr there_write_byte

  ; ignore the spaces
  skip4:
    JSR getbyte
    beq break4
    cmp #' '
  beq skip4 
  break4:
  ; read file type
  .scope 
    loop:
    jsr there_write_byte
    JSR getbyte
    beq break
    cmp #' '
    bne loop
    break:
  .endscope
  pha
    lda #0
    jsr there_write_byte
  pla
  .scope 
    beq break
    loop:
      jsr getbyte
    bne loop
    break:
  .endscope

  jmp next      ; no RUN/STOP -> continue
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
  .data   
    tmp: .word 0 
  .code 
EndMenuHandler

.macro MenuDirectory title
  MenuItem HNDL_DIRECTORY, title
.endmacro

MenuHandler HNDL_FILE
  ACTION:
    lda #<MENU_FILE
    ldy #>MENU_FILE
    jmp go_to_ay
  PRINT:
    jsr print_z_title
    ;jsr print::space
    jsr here_read_byte
    sta print::arg
    jsr here_read_byte
    sta print::arg+1
    lda #'.'
    jsr print::char
    jsr imenu::print_z_from_here
    lda #2
    jsr print::spaces_to
    jsr print::number
  rts
EndMenuHandler

Menu "File", MENU_FILE
  MenuHeading "open"
  MenuHeading "delete"
EndMenu