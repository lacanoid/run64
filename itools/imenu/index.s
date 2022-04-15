.ifndef ::__IMENU_INCLUDED__
::__IMENU_INCLUDED__ = 1

.include "../defs/defs-auto.inc"
.include "../macros/basics.inc"

.include "macros.inc"
.include "../print.s"
.include "../xy.s"

.scope imenu
  .include "imenu-core.s"
  .include "handlers/index.s"
.data
  DEF_BG = 1
  DEF_BRD = 12
  DEF_FG = 0
  DEF_SEL = 11
  DEF_HDR = 6

  COLOR_BG : .byte DEF_BG 
  COLOR_BRD: .byte DEF_BRD
  COLOR_FG : .byte DEF_FG 
  COLOR_SEL: .byte DEF_SEL
  COLOR_HDR: .byte DEF_HDR
  FQUIT: .byte 0
  SELECTED_INDEX: .byte 0
  TOP_INDEX: .byte 0
  PRINT_CNT: .byte 0
  SCROLL_HEIGHT: .byte 0
  PRINT_INDEX: .byte 0
  KEY_CODES:
    .byte $11, $91, $1d, $9d 
    .byte $0d, $03, 'q', 'r'
    .byte 0
    .addr do_next, do_prev, do_action, do_back
    .addr do_action, do_back, do_quit, do_reload
.code

  .proc on_load
    IMov THERE, INIT_THERE
    lda #14
    jsr CHROUT
    jsr restore_colors
    jsr load_root
    jsr there_clear
    jsr fetch_items
    rts
  .endproc 

  .proc main
    jsr on_load
    CClear FQUIT
    main_loop:
      jsr print_menu
      jsr handle_keys
      lda FQUIT
    beq main_loop
    lda #'B'
    print char
    lda #'Y'
    print char
    lda #'E'
    print char
    rts
  .endproc

  .proc print_header
    print reset
    CMov COLOR, COLOR_HDR
    lda CNT_ITEMS
    print number_a
    print rev_on
    ldxy CUR_MENU
    jsr print_item_xy
    print nl
    print rev_off
    rts
  .endproc
  .proc print_menu
    jsr print_header
    lda SCROLL_HEIGHT
    beq empty

    sta PRINT_CNT
    cmp #24
    bcc no_scroll
    full_scroll: 
      ; find TOP_INDEX
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
    no_scroll:
      CMov PRINT_INDEX, TOP_INDEX
    item:
      lda PRINT_INDEX
      pha
        IfEq SELECTED_INDEX
          CMov COLOR, COLOR_SEL
          print rev_on
        Else
          lda #12
          CMov COLOR, COLOR_FG
        EndIf
        print space
      pla
      
      jsr ld_item_a
      jsr print_item_xy
      
      print nl
      print rev_off
      inc PRINT_INDEX
      dec PRINT_CNT
    bne item
    beq break
    empty:
    lda #'?'
    print char
    break:
    print clear_rest
    rts 
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
    jsr ld_item_selected
    lda #METHODS::ACTION
    jsr method_item_xy
    jsr restore_colors
    
    rts
  .endproc

  .proc do_back 
    jmp go_back
  .endproc

  .proc do_reload 
    jsr print_header
    print clear_rest
    jsr there_clear
    jmp fetch_items
  .endproc


  .proc do_quit 
    inc FQUIT
    rts
  .endproc


  .proc on_items_loaded
  /*
   phxy
    ldxy CUR_MENU 
    jsr print::word_xy
    jsr print::space
    ldxy MENU_THERE 
    jsr print::word_xy
    jsr print::space
    ldxy THERE 
    jsr print::word_xy
    jsr WAIT
    jsr idump::main
    ISet 53280,$11
  plxy    
  */
    jsr restore_colors
    CSet SELECTED_INDEX, 0 
    CSet TOP_INDEX, 0 
    lda CNT_ITEMS
    cmp #25
    bcs full_scroll
    sta SCROLL_HEIGHT
    rts
    full_scroll:
    lda #24
    sta SCROLL_HEIGHT
    rts
  .endproc 

  .proc restore_colors 
    CMov EXTCOL, COLOR_BRD
    CMov BGCOL0, COLOR_BG
    rts
  .endproc
.endscope

.proc WAIT
  pha
  wait: 
    inc EXTCOL
    jsr GETIN
  beq wait
  pla
  rts
.endproc

.endif