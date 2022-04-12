.include "defs-auto.inc"
.include "macros/basics.s"

.include "macros.inc"
.include "print.s"
.include "xy.s"

.scope imenu
.include "handlers/index.s"
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

  COLOR_BG = 1
  COLOR_BRD = 12
  COLOR_FG = 0
  COLOR_SEL = 11
  COLOR_HDR = 6

  FQUIT: .byte 0
  CUR_MENU: .word 0
  SELECTED_INDEX: .byte 0
  TOP_INDEX: .byte 0
  PRINT_INDEX:.word 0
  HISTORY_PTR: .byte 0
  OLD_THERE: .word INIT_THERE
  KEY_CODES:
    .byte $11, $91, $1d, $9d 
    .byte $0d, $03, 'q'
    .byte 0
    .addr do_next, do_prev, do_action, do_back
    .addr do_action, do_back, do_quit
  BUILTIN_HANDLERS:
    .word HNDL_HEADING
    .word HNDL_ECHO
    .word HNDL_MENU
  CNT_ITEMS: .byte 0, 0 ; one for alignment
  MENU_ITEMS: .res MAX_ITEMS * 2
  HISTORY: .res MAX_HISTORY * 4
.code

.proc clear_items
  CSet CNT_ITEMS, 0
  rts 
.endproc

.proc add_item_here
  ldx HERE
  ldy HERE+1
  jmp add_item_xy
.endproc

.proc add_item_there
  ldx THERE
  ldy THERE+1
  jmp add_item_xy
.endproc

.proc add_item_xy
  pha
  PushX
  stx rw+1
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
  PopX
  pla
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
  CSet TOP_INDEX, 0 
  rts
.endproc

.proc set_menu_to_the_item
  IMov CUR_MENU, THE_ITEM
  CSet TOP_INDEX, 0 
  rts
.endproc


.proc set_the_item_to_selected
  lda SELECTED_INDEX
  jmp set_the_item_to_a
.endproc

.proc ld_item_a
  clc
  asl
  tax
  lda MENU_ITEMS++1,x
  tay
  lda MENU_ITEMS,x
  tax
  IMov HERE, THE_ITEM
  rts
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



.proc print_item_xy
  stxy THE_ITEM
  phxy
  adxy #3
  stxy HERE 
  plxy
  goxy
  goxy
  jpxy
.endproc


.proc method_item_xy
  stxy THE_ITEM
  jsr here_set_for_method_xy
  goxy
  adxy 
  goxy
  cpy #0
  beq skip
  jsxy
  clc
  rts
  skip: 
  ;pla; pha from before
  sec 
  rts
.endproc


.proc here_set_for_method_xy
  pha
  phxy
    adxy #2
    xyrd 
    beq count_em
    adxy
    bra done
    count_em:
      xyrd 
    bne count_em
    beq done
  done: 
  stxy HERE
  plxy
  pla
  rts 
.endproc 



.proc here_advance_a
  IAddA HERE
  rts
.endproc

.proc here_read_a
  lda HERE
  sta rw+1
  lda HERE+1
  sta rw+2
  rw: lda $FEED  
  IInc HERE
  rts
.endproc

.proc here_read_x
  pha
  ldx #0
  lda (HERE,x)
  IInc HERE
  tax
  pla
  rts
.endproc

.proc here_read_y
  pha
  ldy #0
  lda (HERE),y
  tay
  IInc HERE
  pla
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
  ldxy HERE
  goxy
  stxy HERE
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
  PushX
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
  PopX
  rts
.endproc

.proc history_pop
  PushX
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
  PopX
  rts
.endproc


.proc go_to_here
  jsr history_push
  IMov CUR_MENU, HERE
  CSet SELECTED_INDEX, 0
  CSet TOP_INDEX, 0 
  rts
.endproc

.proc go_to_the_item
  jsr history_push
  IMov CUR_MENU, THE_ITEM
  CSet SELECTED_INDEX, 0 
  CSet TOP_INDEX, 0 
  rts
.endproc

.proc go_back
  jsr history_pop
  CSet SELECTED_INDEX, 0 
  CSet TOP_INDEX, 0 
  rts
.endproc

.proc main
  ISet THERE, INIT_THERE

  lda #14
  jsr CHROUT
  CSet EXTCOL, COLOR_BRD
  CSet BGCOL0, COLOR_BG
  
  jsr load_root
  jsr fetch_items
  main_loop:
    jsr print_menu
    jsr handle_keys
    lda FQUIT
  beq main_loop
  rts
.endproc

.proc print_menu
  jsr print::reset



  lda SELECTED_INDEX
  cmp TOP_INDEX
  bcc top_fix
  sbc #23
  bmi top_ok
  cmp TOP_INDEX
  bcc top_ok
  top_fix:
  sta TOP_INDEX
  top_ok:
  
  CSet COLOR, COLOR_HDR
  jsr print::rev_on
  ldxy CUR_MENU
  jsr print_item_xy
  jsr print::nl
  jsr print::rev_off

  CSet PRINT_INDEX, 0
  item:
    lda PRINT_INDEX
    cmp #24
    bcs break
    adc TOP_INDEX
    cmp CNT_ITEMS
    bcs break
    pha
      IfEq SELECTED_INDEX
        CSet COLOR, COLOR_SEL
        jsr print::rev_on
      Else
        lda #12
        CSet COLOR, COLOR_FG
      EndIf
      jsr print::space
    pla
    jsr ld_item_a
    jsr print_item_xy

    jsr print::nl
    jsr print::rev_off
    inc PRINT_INDEX
    bne item
  break:
  jmp print::clear_rest
.endproc

.proc handle_keys
  wait: 
    jsr GETIN
  beq wait
    ldxy #KEY_CODES
    jsr xy::lookup
  bcs wait
  jpxy
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
  jsr ld_item_a
  lda #METHODS::ACTION
  jsr method_item_xy
  jmp fetch_items
.endproc

.proc do_back 
  jsr go_back
  jmp fetch_items
.endproc

.proc do_quit 
  inc FQUIT
  rts
.endproc


.proc fetch_items ; get items from the current menu
  jsr clear_items
  ldxy CUR_MENU 
  lda #METHODS::ITEMS
  jsr method_item_xy
  CSet EXTCOL, COLOR_BRD
  CSet BGCOL0, COLOR_BG
  rts
.endproc


.endscope