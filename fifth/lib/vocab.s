.macro GenericEntry id, name, label, token
  .scope
    ::.ident (.string(name))=entry 
    entry:
      .byte id
      .word code 
      .word next
      .byte token
      .ifblank label
        .asciiz .string(name)
      .else
        .asciiz label
      .endif
    code:
  .endscope
.endmacro

.macro rEntry name, label
  GenericEntry bytecode::tPTR, name, label, bytecode::tRUN
.endmacro

.macro jEntry name, label
  GenericEntry bytecode::tPROC, name, label, bytecode::tPROC
.endmacro

.macro cEntry name, label
  GenericEntry bytecode::tPROC, name, label, bytecode::tCTL
.endmacro

.scope vocab 
  name_offset = 6
  token_offset = 5
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