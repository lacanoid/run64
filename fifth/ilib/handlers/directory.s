MenuHandler HNDL_DIRECTORY
  PRINT:
    jsr print_z_from_here
    jsr print::space
    jsr here_read_x
    txa
    jsr print::number_a
    rts
  ACTION:
    jmp go_to_the_item
  ITEMS:
    inc 53280
    CSet STATUS,0
    LDA #dirname_end-dirname
    ldxy #dirname
    JSR SETNAM

    LDA #$02       ; filenumber 2
    jsr here_read_x
    LDY #$02       ; secondary address 0 (required for dir reading!)
    JSR SETLFS
    JSR OPEN       ; (open the directory)
    BCC ok
    jmp error     ; quit if OPEN failed
    ok:
    lda STATUS
    JmpTrue error 
    
    LDX #$02       ; filenumber 2
    JSR CHKIN
    
    jsr add_item_there
    lda #<HNDL_DISK
    jsr there_write_byte
    lda #>HNDL_DISK
    jsr there_write_byte
    lda #0
    jsr there_write_byte

    ldy #142
    jsr skip_y
    
    ldy #18             ; disk name
    jsr read_sy     

    ldy #2              ; DISK_ID
    jsr read_y

    ldy #1              
    jsr skip_y

    ldy #2              ; OS
    jsr read_y
    
    ldy #89
    jsr skip_y

    lda #$ff
    sta cnt
    read_file:
      JSR READST      ; call READST (read status byte)
      BNE exit
      
      inc cnt
      lda cnt
      cmp #32
      bcs exit
      and #7
      beq not_first
        ldy #2
        jsr skip_y
      not_first:
            
      ldy #3
      jsr store_y      ; store TYPE, TRACK, SECTOR

      lda tmp+2
      bne found_file
        lda #27
        jsr skip_y
        jmp read_file
      found_file: 
      jsr add_item_there
      lda #<HNDL_FILE
      jsr there_write_byte
      lda #>HNDL_FILE
      jsr there_write_byte
      lda #0
      jsr there_write_byte

      ldy #16
      jsr read_sy      ; FILENAME
      
      ldy #3
      jsr flush_y      ; output TYPE, TRACK, SECTOR
      
      ldy #9
      jsr skip_y
      ldy #2
      jsr read_y       ; SIZE 
    jmp read_file
    error:
      brk
      ; Akkumulator contains BASIC error code

      ; most likely error:
      ; A = $05 (DEVICE NOT PRESENT)
    exit:
      JSR $FFCC     ; call CLRCHN
      LDA #$02       ; filenumber 2
      JSR $FFC3      ; call CLOSE
      lda #0
      sta 53280
      wait:
        inc 53280
        dec 53280
        jsr GETIN
        
      beq wait
      RTS

    getbyte:
      JSR READST      ; call READST (read status byte)
      BNE end       ; read error or end of file
      inc 53280
      
      jsr CHRIN      ; call CHRIN (read byte from directory)
      rts
      .data
        got_byte: .byte 0
      .code
    end:
      PLA            ; don't return to dir reading loop
      PLA
      PLA
      PLA
      ;brk
      JMP exit
    
    skip_y:
      jsr getbyte
      dey 
    bne skip_y 
    rts
    read_y:
      jsr getbyte
      jsr there_write_byte 
      dey 
    bne read_y 
    rts  
   
    read_sy:
      jsr getbyte
      cmp #$A0
      beq readsy_end
      jsr there_write_byte
      dey 
    bne read_sy
    readsy_done:
    lda #0
    jmp there_write_byte
    readsy_end:
    dey
    jsr skip_y  
    beq readsy_done

    store_y:
      jsr getbyte
      sta tmp,y
      dey 
    bne store_y 
    rts   

    flush_y:
      lda tmp,y
      jsr there_write_byte 
      dey 
    bne flush_y
    rts   

  dirname:  .byte "$"      ; filename used to access directory
  dirname_end:
  .data   
    cnt: .byte 0
    tmp: 
    .res 4
  .code 
EndMenuHandler

.macro MenuDirectory title, device
  MenuItem HNDL_DIRECTORY, title
  .ifnblank device
    .byte device
  .else 
    .byte 8
  .endif
.endmacro

MenuHandler HNDL_DISK
  PRINT:
    jsr print_z_title
    ;jsr print::space
    rts
    jsr here_read_a
    sta print::arg
    jsr here_read_a
    sta print::arg+1
    lda #'.'
    jsr print::char
    jsr imenu::print_z_from_here
    lda #2
;    jsr print::spaces_to
    jsr print::number
  rts
EndMenuHandler

.data
  CURRENT_FILE:
  .addr 0
.code

MenuHandler HNDL_FILE
  ACTION:
    IMov CURRENT_FILE, THE_ITEM
    jmp go_to_the_item
  ITEMS:
    ldxy #MENU_FILE 
    lda #METHODS::ITEMS
    jmp method_item_xy
  PRINT:
    jsr print_z_title
    ;jsr print::space
    lda #30
    jsr print::spaces_to

    jsr here_read_a
    and #7
   
    clc
    asl
    asl
    ldxy #FILE_TYPES
    jsr print::z_at_xy_plus_a
    jsr print::space 
    lda #2
    jsr here_advance_a
    jsr here_read_x
    jsr here_read_y
    jsr print::number_xy
    rts 
  FILE_TYPES:
  .byte "del",0
  .byte "seq",0
  .byte "prg",0
  .byte "usr",0
  .byte "rel",0
EndMenuHandler

Menu "File", MENU_FILE
  MenuHeading "open"
  MenuHeading "delete"
EndMenu