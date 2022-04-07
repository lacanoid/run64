MenuHandler HNDL_MENU
  ACTION:
    IMov CUR_MENU,CUR_ITEM
    CSet SELECTED_INDEX, 0 
    rts
  ITEMS:
    jsr here_set_to_cur_item_body
    loop:
      cmp #0
      beq exit 
      IMov tmp, HERE
      IAddB HERE, 2
      ;lda #'1'
      ;jsr print_debug
      IMov CUR_ITEM, HERE
      ;lda #'2'
      ;jsr print_debug
      jsr add_item
      
      IMov HERE, tmp
      jsr here_deref
      lda HERE+1
      
    bne loop
  exit:
    rts
  .data   
    tmp: .word 0 
  .code 
EndMenuHandler

MenuHandler HNDL_MENU_LINK
  ACTION:
    jsr here_set_to_cur_item_body
    jsr here_read_item
    IMov CUR_MENU,CUR_ITEM
    CSet SELECTED_INDEX, 0 
    rts
EndMenuHandler


.macro MenuLink title, id
  MenuItem HNDL_MENU_LINK, title
  .addr id
.endmacro


.proc print_z_title
  jsr here_set_to_cur_item
  lda #2
  jsr here_advance_a
  jsr here_deref
  jmp print_z_from_here
  rts
.endproc