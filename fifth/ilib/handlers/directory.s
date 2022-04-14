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
    jsr there_begin_items

    inc 53280
    CSet STATUS,0
    lda #dirname_end-dirname
    ldxy #dirname
    jsr SETNAM

    lda #0
    stx STATUS

    lda #$02       ; filenumber 2
    jsr here_read_x
    stx FA

    ldy #$02       ; secondary address 0 (required for dir reading!)
    jsr SETLFS
    jsr OPEN       ; (open the directory)
    bcc ok
    jmp error     ; quit if OPEN failed
    ok:
    
    ldx #$02       ; filenumber 2
    jsr CHKIN
    
    ldxy #HNDL_DISK
    jsr there_begin_item

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

    jsr there_finish_item
    lda #$ff
    sta cnt
    read_file:
      jsr READST      ; call READST (read status byte)
      bne exit
      
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

      ldxy #HNDL_FILE
      jsr there_begin_item

      ldy #16
      jsr read_sy      ; FILENAME
      
      ldy #3
      jsr flush_y      ; output TYPE, TRACK, SECTOR
      
      ldy #9
      jsr skip_y
      ldy #2
      jsr read_y       ; SIZE 

      jsr there_finish_item
    jmp read_file
    error:
      ; Akkumulator contains BASIC error code

      ; most likely error:
      ; A = $05 (DEVICE NOT PRESENT)
    exit:
      jsr there_cancel_item
      lda #$02       ; filenumber 2
      jsr CLOSE      ; call CLOSE
      jsr CLRCHN     ; call CLRCHN
      rts

    getbyte:
      jsr READST      ; call READST (read status byte)
      bne end       ; read error or end of file
      inc 53280
      
      jsr CHRIN      ; call CHRIN (read byte from directory)
      rts
    end:
      ;jsr there_cancel_item
      pla            ; don't return to dir reading loop
      pla
      pla
      pla
      ;brk
      jmp exit
    
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