.data
  CUR_ITEM: .word 9
  HERE = $FD
  METHOD = $FB
  CUR_INDEX = $2
  
  print_char = CHROUT 

  CUR_MENU: .word 0

  SELECTED_INDEX: .byte 0
  PRINT_INDEX:.word 0
  CNT_ITEMS: .byte 0, 0 ; one for alignment

  MENU_ITEMS: .res 128*4

  BUILTIN_HANDLERS:
    .word HNDL_HEADING
    .word HNDL_ECHO
    .word HNDL_MENU
.code

.proc clear_items
  CSet CNT_ITEMS, 0
  rts 
.endproc

.proc add_item
  lda CNT_ITEMS
  inc CNT_ITEMS
  clc 
  ;asl 
  asl
  tax 

  lda CUR_ITEM
  sta MENU_ITEMS+2,x
  lda CUR_ITEM+1
  sta MENU_ITEMS+3,x
  rts
.endproc

.proc set_cur_item_to_menu
  IMov CUR_ITEM, CUR_MENU
  rts
.endproc


.proc set_cur_item_to_selected
  lda SELECTED_INDEX
  jmp set_cur_item_to_a
.endproc

.proc set_cur_item_to_a
  clc
  asl
  tax
  lda MENU_ITEMS+2,x
  sta CUR_ITEM
  lda MENU_ITEMS+3,x
  sta CUR_ITEM+1
  IMov HERE, CUR_ITEM
  rts
.endproc

.proc handler_method_a
  pha
  jsr here_set_to_cur_item
  jsr here_deref 
  pla
  pha 
  jsr here_advance_a
  jsr here_deref
  pla
  lda HERE+1
  bne do_it
  rts
  do_it:
  IMov METHOD, HERE
  jsr here_set_to_cur_item
  jmp (METHOD)
.endproc

.proc print_item_a
  jsr set_cur_item_to_a
  lda #0
  jmp handler_method_a
.endproc

.proc action_item_a
  jsr set_cur_item_to_a
  lda #2
  jmp handler_method_a
.endproc

.proc fetch_items ; get items from the current menu
  jsr set_cur_item_to_menu

  jsr clear_items
  lda #4
  jmp handler_method_a
.endproc

.proc set_here_to_cur_item_plus_a
  pha
    IMov HERE, CUR_ITEM
  pla
  IAddA HERE
  rts
.endproc

.proc here_set_to_cur_item_body
  jsr here_set_to_cur_item
  lda #4
  jmp here_advance_a
.endproc 

.proc here_set_to_cur_item

  IMov HERE, CUR_ITEM
  rts
.endproc 

.proc here_advance_a
  IAddA HERE
  rts
.endproc

.proc here_read_byte
  ldx #0
  lda (HERE,x)
  IInc HERE
  rts
.endproc

.proc here_read_item
  jsr here_read_byte
  sta CUR_ITEM
  jsr here_read_byte
  sta CUR_ITEM+1
  rts
.endproc

.proc here_deref
  jsr here_read_byte
  pha
  jsr here_read_byte
  sta HERE+1
  pla 
  sta HERE 
  rts
.endproc


.proc print_z_from_here
  ldy #20
  char:
    dey
    beq done
    jsr here_read_byte
    cmp #0
    beq done
    jsr print_char
  clv
  bvc char
  done:
  rts
.endproc
