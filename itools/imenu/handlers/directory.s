.include "../../pipe.s"
.include "../../file.s"

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
    ldxy #file::read_busy
    pipe set_input
    ldxy #there_write_a
    pipe set_output
    ldxy #error
    pipe set_catch

    lda #$ff
    sta cnt
    
    jsr there_begin_items

    inc 53280
    jsr here_read_a
    pha
      print number_a
    pla 
    ldxy #dirname
    file open_r
    bcs error             ; quit if OPEN failed
    sta rwclose+1         ; save the file number 

    ldxy #HNDL_DISK
    jsr there_begin_item

    ldy #142
    pipe skip_y
    
    ldy #18             ; disk name
    lda #$a0
    pipe copy_until     

    ldy #2              ; DISK_ID
    pipe copy_y

    ldy #1              
    pipe skip_y

    ldy #2              ; OS
    pipe copy_y
    
    ldy #89
    pipe skip_y

    jsr there_finish_item
    each_file:
      jsr READST      ; call READST (read status byte)
      bne exit
      
      inc cnt
      lda cnt
      and #7
      beq not_first
        ldy #2
        pipe skip_y
      not_first:

      ldy #3
      pipe buffer_y      ; store TYPE, TRACK, SECTOR

      lda pipe::buffer+2 ; if track is 0, it doesn't exist
      bne found_file     
        lda #27
        pipe skip_y
        jmp each_file
      found_file: 

      ldxy #HNDL_FILE
      jsr there_begin_item

      ldy #16
      lda #$a0
      pipe copy_until      ; FILENAME
      
      ldy #3
      pipe flush_y      ; output TYPE, TRACK, SECTOR
      
      ldy #9
      pipe skip_y
      ldy #2
      pipe copy_y       ; SIZE 

      jsr there_finish_item
    jmp each_file
    exit:      
      rwclose: lda #$02       ; filenumber 2
      jsr CLOSE      ; call CLOSE
      jsr CLRCHN     ; call CLRCHN
      rts
   
    .proc error
      pha
      jsr there_cancel_item
      pla
      cmp #0
      beq exit
      pha
      ldxy #HNDL_FILE_ERROR
      jsr there_begin_item
      jsr there_write_zero
      pla
      jsr there_write_a
      jsr there_finish_item
      jmp exit
    .endproc 
    .proc readbyte
      file read
      inc 53280
      rts
    .endproc
  dirname:  .byte "$" ,0     ; filename used to access directory
  .data   
    cnt: .byte 0
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
EndMenuHandler


MenuHandler HNDL_FILE_ERROR
  PRINT:
    jsr print_z_title
    print "error "
    jsr here_read_a
    print number_a
    rts
EndMenuHandler

MenuHandler HNDL_FILE
  ACTION:
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
  MenuAction "read"
    ldxy CUR_MENU
    adxy #3
    lda #8
    file open_r
    bcs error
    pha
    loop: 
      file read_busy
      bcs done
      print char
      JSR $FFE1 
    bne loop
    done:
      pla
      jsr CLOSE
      jsr CLRCHN
      wait: jsr GETIN
      beq wait 
      rts
    error:
      print "error"
    rts
EndMenu