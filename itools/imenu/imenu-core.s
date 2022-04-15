
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
  PREVIOUS: .word 0
  CUR_MENU: .word 0
  HISTORY_PTR: .byte 0
  MENU_THERE: .word INIT_THERE
  LATEST: .word INIT_THERE
  CNT_ITEMS: .byte 0, 0 ; one for alignment
  MENU_ITEMS: .res MAX_ITEMS * 2
  HISTORY: .res MAX_HISTORY * 4
.code

.proc clear_items
  CSet CNT_ITEMS, 0
  rts 
.endproc

.proc add_item_xy
  pha
  PushX
  stx rw+1
  lda CNT_ITEMS
  cmp #MAX_ITEMS
  bcs die
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
  die:
  brk
.endproc

.proc load_items 
  jsr clear_items
 
  ldxy MENU_THERE
  goxy
  loop:
    xyldh
    beq exit
    adxy #2
    jsr add_item_xy
    sbxy #2
    goxy
  bra loop
  exit:
  jmp on_items_loaded
.endproc

.proc ld_item_selected
  lda SELECTED_INDEX
.endproc
; passthrough
.proc ld_item_a
  clc
  asl
  ldxy #MENU_ITEMS
  adxy
  goxy
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
  jsr here_read_a
  tax
  pla
  rts
.endproc

.proc here_read_y
  pha
  jsr here_read_a
  tay
  pla
  rts
.endproc

.proc there_clear
  ldxy MENU_THERE
  stxy THERE
  lda #0
  xyst
  xysth 
  rts
.endproc 
 
.proc there_write_zero
  lda #0
.endproc
;passthrough
.proc there_write_a
  PushX
  ldx #0
  sta (THERE,x)
  IInc THERE
  PopX
  clc
  rts
.endproc
.proc there_write_xy
  stixy THERE
  IAddB THERE,2
  clc
  rts
.endproc

.proc there_cancel_item 
  ldxy LATEST
  adxy #2
  stxy THERE
  rts
.endproc

.proc there_finish_item 
  ldxy THERE
  stixy LATEST
  stxy LATEST
  lda #0
  xywr
  xywr 
  stxy THERE
  rts
.endproc

.proc there_begin_items
  ; expects handler address in xy
  ldxy THERE
  adxy #2
  jsr there_write_xy
  stxy LATEST
  lda #0
  jsr there_write_a
  jsr there_write_a
  rts
.endproc


.proc there_begin_item  
  ; expects handler address in xy
  jsr there_write_xy
  lda #0
  jsr there_write_a
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
  phxy
  ldx HISTORY_PTR
  cpx #MAX_HISTORY*4
  bcs skip
    lda CUR_MENU
    sta HISTORY,x
    inx 
    lda CUR_MENU+1
    sta HISTORY,x
    inx 
    lda MENU_THERE
    sta HISTORY,x
    inx 
    lda MENU_THERE+1
    sta HISTORY,x
    inx
    stx HISTORY_PTR 
    IMov MENU_THERE, THERE
    jsr there_clear
  skip:
  plxy
  rts
.endproc

.proc history_pop
  PushX
  IMov THERE, MENU_THERE
  ldx HISTORY_PTR
  beq skip
    dex 
    lda HISTORY,x
    sta MENU_THERE+1
    dex
    lda HISTORY,x
    sta MENU_THERE
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

.proc go_to_xy
  jsr history_push
  stxy CUR_MENU
  CSet SELECTED_INDEX, 0
  CSet TOP_INDEX, 0 
  jmp fetch_items
.endproc

.proc go_to_here
  ldxy HERE
  jmp go_to_xy  
.endproc

.proc go_to_the_item
  ldxy THE_ITEM
  jmp go_to_xy
.endproc

.proc go_back
  jsr history_pop
  jmp load_items
.endproc

.proc fetch_items ; get items from the current menu
  ldxy CUR_MENU 
  lda #METHODS::ITEMS
  jsr method_item_xy
  jmp load_items
.endproc