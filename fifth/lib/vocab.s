.scope vocab
  exec_offset = 1
  flags_offset = 3
  next_offset = 4
  name_offset = 6
  
  is_immediate = 1

  compile_offset = 6
  list_offset = 8
  cursor: .word 0
  ::VP: .addr VOCAB_START
  arg: .addr 0

  .proc reset_cursor
    IMov cursor, VP
    rts 
  .endproc ; vocab::reset_cursor

  .proc advance_cursor ; leaves high byte of cursor address in a
    PeekX cursor, next_offset+1
    pha 
    dex
    PeekX cursor
    sta cursor
    pla
    sta cursor+1
    rts
  .endproc ; vocab::advance_cursor
  
  .proc find_entry
    ; expects pointer to input in arg
    ; returns sec on failure
    ; otherwise clc and the length matched in x
    clc
    jsr reset_cursor
    loop:
      jsr match_entry
      bcc found
      jsr advance_cursor
      bne loop
      sec
      rts
    found:
      clc
      rts
  .endproc 

  .proc match_entry
    ldy #name_offset
    ldx #0
    loop:
      PeekY cursor
      beq maybe_matched ; reached the end of the entry name
      sta rewrite+1
      PeekX arg
      inx
      iny
      rewrite:
      cmp #$FF
    beq loop
    failed:
      sec
      rts
    maybe_matched:
      PeekX arg
      cmp #33           ; check if the word has ended in the source
      bcs failed
      txa
      clc
      rts
  .endproc 

  .proc create_entry

  .endproc

  .proc print_name_at_cursor
    IMov print::arg, cursor
    jmp _print_name_
  .endproc

  .proc print_name
    IMov print::arg, arg
  .endproc
  .proc _print_name_
    IAddB print::arg, name_offset
    jsr print::print_z
    rts
  .endproc
.endscope


.scope heap
  .proc write_zero
    lda #0
    ;continue
  .endproc
  
  .proc write
    WriteA HEAP_END
    rts
  .endproc
.endscope

.scope here
  arg: .word 0
  .proc write_zero
    lda #0
    ;continue
  .endproc
  
  .proc write
    WriteA HERE_PTR
    rts
  .endproc

  .proc write_string
    loop:
      ReadA arg
      beq done
      jsr write
      bra loop
    done:
    jsr write_zero
    rts
  .endproc
.endscope
