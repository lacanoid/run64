.feature c_comments
jmp main
.include "defs64.inc"
.include "macros/helpers.s"
.include "utils.s"
MSGBAS = 0

.include "imenu_lib/macros.inc"
.include "imenu_lib/core.s"
.include "imenu_lib/handlers/index.s"
.include "imenu_lib/menu_root.s"


.proc main
  ISet 53280,0
  CSet COLOR, 15
  jsr load_root
  main_loop:
    jsr fetch_items
    jsr print_menu
    jsr handle_keys
  jmp main_loop
  rts
.endproc

.proc print_menu
  jsr clear_screen
  CSet PRINT_INDEX, 0
  item:
    jsr print_nl
    lda PRINT_INDEX
  cmp CNT_ITEMS
  beq break
    lda PRINT_INDEX
    pha
      cmp SELECTED_INDEX
      beq is_selected
      not_selected:
        lda #12
        sta COLOR
        jsr print_space
        bne then
      is_selected:
        lda #1
        sta COLOR
        lda #'>'
        jsr print_char
      then:
    pla
    jsr print_item_a
    inc PRINT_INDEX
    bne item
  break:
  rts
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
  cmp #3
  beq key_back
  jmp wait
  key_next: jmp do_next
  key_prev: jmp do_prev
  key_action: jmp do_action
  key_back:
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
  jmp action_item_a
.endproc

.proc print_debug
  pha
  lda #'['
  jsr CHROUT
  pla
  jsr CHROUT
  lda #':'
  jsr CHROUT
  ;lda CUR_HANDLER+1
  ;jsr WRTWO
  ;lda CUR_HANDLER
  ;jsr WRTWO
  ;lda #':'
  ;jsr CHROUT
  lda CUR_ITEM+1
  jsr WRTWO
  lda CUR_ITEM
  jsr WRTWO
  lda #':'
  jsr CHROUT
  lda HERE+1
  jsr WRTWO
  lda HERE
  jsr WRTWO
  lda #']'
  jsr CHROUT
  wait:
    jsr GETIN
  beq wait
  rts
.endproc 

.proc print_nl
  pha 
  lda #13
  jsr CHROUT
  pla
  rts
.endproc
.proc print_space
  pha 
  lda #' '
  jsr CHROUT
  pla
  rts
.endproc

.proc clear_screen
  pha 
  lda #147
  jsr CHROUT
  pla
  rts
.endproc
