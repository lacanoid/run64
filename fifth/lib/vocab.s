.macro Entry name
  .scope
    jmp exec
    .word next
    .asciiz name
    exec:
  .endscope
.endmacro

.macro rExec entry
  ISet runtime::IP, entry
  jsr runtime::run
.endmacro

.macro rEntry name, label
  .scope
    .ifblank label
      ::.ident (.string(name))=entry 
    .else
      ::.ident (.string(label))=entry
    .endif
    entry:
      .byte 0
      .word code 
      .word next
      .asciiz .string(name)
    code:
  .endscope
.endmacro

.macro Exec entry
  jsr entry
.endmacro

.scope vocab 
  cursor = $FB
  bottom: .word VOCAB_START

  .proc reset_cursor
    IMov cursor, bottom
    rts 
  .endproc ; vocab::reset_cursor

  .proc advance_cursor ; leaves high byte of cursor address in a
    ldy #3
    lda (cursor),y
    tax 
    iny 
    lda (cursor),y
    
    stx cursor
    sta cursor+1
    rts
  .endproc ; vocab::advance_cursor
.endscope