

.macro GenericEntry id, name, label
  .scope
    ::.ident (.string(name))=entry 
    entry:
      .byte id
      .word code 
      .word next
      .ifblank label
        .asciiz .string(name)
      .else
        .asciiz label
      .endif
    code:
  .endscope
.endmacro

.macro rEntry name, label
  GenericEntry bytecode::tPTR, name, label
.endmacro

.macro jEntry name, label
  GenericEntry bytecode::tJMP, name, label
.endmacro

.macro cEntry name, label
  GenericEntry bytecode::tCTL, name, label
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