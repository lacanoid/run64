.include "defs-auto.inc"
.include "macros/basics.s"

.include "ilib/macros.inc"
.include "ilib/print.s"

.scope imenu
.include "ilib/handlers/index.s"
.data
  .ifdef __C128__
    INIT_THERE=$9000
  .else 
    INIT_THERE=$C000
  .endif    
  
  MAX_HISTORY = 16
  MAX_ITEMS = 128
  
  THE_ITEM: .word 9
  HERE = $FD
  THERE = $FB
  CUR_INDEX = $2
  
  CUR_MENU: .word 0

  SELECTED_INDEX: .byte 0
  PRINT_INDEX:.word 0
  CNT_ITEMS: .byte 0, 0 ; one for alignment

  MENU_ITEMS: .res MAX_ITEMS * 2

  HISTORY: .res MAX_HISTORY * 4
  HISTORY_PTR: .byte 0
  OLD_THERE: .word INIT_THERE
  BUILTIN_HANDLERS:
    .word HNDL_HEADING
    .word HNDL_ECHO
    .word HNDL_MENU
.code

.proc clear_items
  CSet CNT_ITEMS, 0
  rts 
.endproc

.proc add_item_here
  lda HERE
  ldy HERE+1
  jmp add_item_ay
.endproc

.proc add_item_there
  lda THERE
  ldy THERE+1
  jmp add_item_ay
.endproc

.proc add_item_ay
  sta rw+1
  lda CNT_ITEMS
  cmp #MAX_ITEMS
  bcs skip
    inc CNT_ITEMS
    clc 
    asl
    tax 
    rw: lda #$FF
    sta MENU_ITEMS+0,x
    tya
    sta MENU_ITEMS+1,x
  skip:
  rts
.endproc

.proc set_the_item_to_menu
  IMov THE_ITEM, CUR_MENU
  rts
.endproc

.proc set_menu_to_ay
  sta CUR_MENU
  sty CUR_MENU+1
  CSet SELECTED_INDEX, 0 
  rts
.endproc

.proc set_menu_to_the_item
  IMov CUR_MENU, THE_ITEM
  CSet SELECTED_INDEX, 0 
  rts
.endproc


.proc set_the_item_to_selected
  lda SELECTED_INDEX
  jmp set_the_item_to_a
.endproc

.proc set_the_item_to_a
  clc
  asl
  tax
  lda MENU_ITEMS+0,x
  sta THE_ITEM
  lda MENU_ITEMS+1,x
  sta THE_ITEM+1
  IMov HERE, THE_ITEM
  rts
.endproc

.proc handler_method_a
  pha
  jsr here_set_to_the_item
  jsr here_deref 
  pla
  pha 
  jsr here_advance_a
  jsr here_deref
  pla
  pha
  IMov rewrite+1, HERE
  lda HERE+1
  beq skip
  pla
  jsr here_set_for_method_a
  rewrite:
  jsr $FADE
  clc
  rts
  skip: 
  pla
  sec 
  rts
.endproc


.proc print_item_a
  jsr set_the_item_to_a
.endproc
;passthrough
.proc print_the_item
  lda #METHODS::PRINT
  jmp handler_method_a
.endproc

.proc action_item_a
  jsr set_the_item_to_a
.endproc
;passthrough
.proc action_the_item  
  lda #METHODS::ACTION
  jmp handler_method_a
.endproc

.proc fetch_items ; get items from the current menu
  jsr set_the_item_to_menu
  jsr clear_items
  lda #METHODS::ITEMS
  jmp handler_method_a
.endproc

.proc here_set_for_method_a
  cmp #METHODS::PRINT 
  beq skip
    lda #2
    jsr here_set_to_the_item_plus_a
    jsr here_read_a
    beq count_em
    jsr here_advance_a
    rts
    count_em:
    jsr here_read_a
    bne count_em
    rts
  skip:
  lda #3
  jmp here_set_to_the_item_plus_a
.endproc 

.proc here_set_to_the_item_plus_a
  clc
  adc THE_ITEM
  sta HERE
  lda #0
  adc THE_ITEM+1
  sta HERE+1
  rts 
.endproc 


.proc here_set_to_the_item
  IMov HERE, THE_ITEM
  rts
.endproc 

.proc here_advance_a
  IAddA HERE
  rts
.endproc

.proc here_read_a
  stx rw+1
  ldx #0
  lda (HERE,x)
  IInc HERE
  pha 
  rw: ldx #0
  pla
  rts
.endproc

.proc here_read_x
  ldx #0
  lda (HERE,x)
  IInc HERE
  tax
  rts
.endproc

.proc here_read_y
  ldy #0
  lda (HERE),y
  tay
  IInc HERE
  rts
.endproc

.proc here_write_byte
  ldx #0
  sta (HERE,x)
  IInc HERE
  rts
.endproc


.proc there_write_byte
  ldx #0
  sta (THERE,x)
  IInc THERE
  rts
.endproc

.proc here_read_item
  jsr here_read_a
  sta THE_ITEM
  jsr here_read_a
  sta THE_ITEM+1
  rts
.endproc

.proc here_deref
  jsr here_read_a
  pha
  jsr here_read_a
  sta HERE+1
  pla 
  sta HERE 
  rts
.endproc


.proc print_z_from_here
  char:
    jsr here_read_a
    cmp #0
    beq done
    jsr print::char
  clv
  bvc char
  done:
  rts
.endproc

.proc history_push
  ldx HISTORY_PTR
  cpx #MAX_HISTORY*4
  bcs skip
    lda CUR_MENU
    sta HISTORY,x
    inx 
    lda CUR_MENU+1
    sta HISTORY,x
    inx 
    lda OLD_THERE
    sta HISTORY,x
    inx 
    lda OLD_THERE+1
    sta HISTORY,x
    inx
    stx HISTORY_PTR 
    IMov OLD_THERE, THERE
  skip:
  rts
.endproc

.proc history_pop
  ldx HISTORY_PTR
  beq skip
    dex 
    lda HISTORY,x
    sta OLD_THERE+1
    sta THERE+1
    dex
    lda HISTORY,x
    sta OLD_THERE
    sta THERE
    dex
    lda HISTORY,x
    sta CUR_MENU+1
    dex
    lda HISTORY,x
    sta CUR_MENU
    stx HISTORY_PTR 
  skip:
  rts
.endproc

.proc go_to_ay
  sty rwy+1
  sta rwa+1
  jsr history_push
  rwa: lda #$ff 
  sta CUR_MENU
  rwy: ldy #$ff 
  sty CUR_MENU+1
  CSet SELECTED_INDEX, 0 
  rts
.endproc

.proc go_to_here
  jsr history_push
  IMov CUR_MENU, HERE
  CSet SELECTED_INDEX, 0 
  rts
.endproc

.proc go_to_the_item
  jsr history_push
  IMov CUR_MENU, THE_ITEM
  CSet SELECTED_INDEX, 0 
  rts
.endproc

.proc go_back
  jsr history_pop
  CSet SELECTED_INDEX, 0 
  rts
.endproc

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
  bra main_loop
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
      IfEq SELECTED_INDEX
        lda #1
        sta COLOR
        lda #'>'
        jsr print::char
      Else
        lda #12
        sta COLOR
        jsr print::space
      EndIf
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
    JmpEq #$11, do_next
    JmpEq #$91, do_prev
    JmpEq #$0D, do_action
    JmpEq #$1D, do_action
    JmpEq #$03, do_back
    JmpEq #$9D, do_back
  jmp wait
.endproc

.proc load_root
  ISet CUR_MENU, MENU_ROOT
  rts
.endproc

.proc do_next
  inc SELECTED_INDEX
  lda SELECTED_INDEX
  IfEq CNT_ITEMS
    lda #0
    sta SELECTED_INDEX
  EndIf
  rts
.endproc

.proc do_prev
  dec SELECTED_INDEX
  IfNeg 
    lda CNT_ITEMS
    sta SELECTED_INDEX
    dec SELECTED_INDEX
  EndIf
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
.endscope