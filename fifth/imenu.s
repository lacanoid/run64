.feature c_comments
jmp main
.include "defs64.inc"
.include "macros/helpers.s"

.include "imenu_lib/macros.inc"
.include "imenu_lib/print.s"
.include "imenu_lib/core.s"
.include "imenu_lib/handlers/index.s"
.include "imenu_lib/idump.s"
.include "imenu_lib/menu_root.s"

.proc main
  ISet THERE, INIT_THERE

  lda #14
  jsr CHROUT
  ISet 53280,0
  CSet COLOR, 15
  
  jsr load_root
  jsr fetch_items
  main_loop:
    jsr print_menu
    jsr handle_keys
  jmp main_loop
  rts
.endproc

.proc print_menu
  jsr print::reset
  CSet PRINT_INDEX, 0
  jsr set_the_item_to_menu
  CSet COLOR, 1
  jsr print::rev_on
  lda #0
  jsr handler_method_a
  jsr print::nl
  jsr print::rev_off
  item:
    lda PRINT_INDEX
    cmp CNT_ITEMS
    beq break
    pha
      cmp SELECTED_INDEX
      beq is_selected
      not_selected:
        lda #12
        sta COLOR
        jsr print::space
        bne then
      is_selected:
        lda #1
        sta COLOR
        lda #'>'
        jsr print::char
      then:
    pla
    jsr print_item_a
    jsr print::nl
    inc PRINT_INDEX
    bne item
  break:
  jmp print::clear_rest
.endproc

.proc handle_keys
  wait: 
  jsr GETIN
  beq wait
  cmp #$11
  beq key_next
  cmp #$91
  beq key_prev
  cmp #13
  beq key_action
  cmp #$1D
  beq key_action
  cmp #3
  beq key_back
  cmp #$9D
  beq key_back
  jmp wait
  key_next: jmp do_next
  key_prev: jmp do_prev
  key_action: jmp do_action
  key_back: jmp do_back
  jmp wait
.endproc

.proc load_root
  ISet CUR_MENU, MENU_ROOT
  rts
.endproc

.proc do_next
  inc SELECTED_INDEX
  lda SELECTED_INDEX
  cmp CNT_ITEMS
  bne not_last
    lda #0
    sta SELECTED_INDEX
  not_last:
  rts
.endproc

.proc do_prev
  dec SELECTED_INDEX
  bpl not_first
    lda CNT_ITEMS
    sta SELECTED_INDEX
    dec SELECTED_INDEX
  not_first:
  rts
.endproc

.proc do_action 
  lda SELECTED_INDEX
  jsr action_item_a
  jmp fetch_items
.endproc

.proc do_back 
  jsr go_back
  jmp fetch_items
.endproc

.proc print_debug
  pha
  /*
  lda #'['
  jsr print::char
  pla
  jsr print::char
  lda #':'
  jsr print::char
  lda THE_ITEM+1
  jsr print::number_a
  lda THE_ITEM
  jsr WRTWO
  lda #':'
  jsr CHROUT
  lda HERE+1
  jsr WRTWO
  lda HERE
  jsr WRTWO
  lda #':'
  jsr CHROUT
  lda THERE+1
  jsr WRTWO
  lda THERE
  jsr WRTWO
  lda #']'
  jsr CHROUT
  */
  wait:
    jsr GETIN
  beq wait
  rts
.endproc 
.code
__PROGRAM_END__: