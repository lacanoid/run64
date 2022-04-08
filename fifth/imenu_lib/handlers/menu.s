MenuHandler HNDL_MENU
  ACTION:
    jmp go_to_the_item
  ITEMS:
    ;jsr here_set_to_the_item_body
    lda HERE+1
    loop:
      cmp #0
      beq exit

      IMov tmp, HERE
      IAddB HERE, 2
      ;lda #'1'
      ;jsr print_debug
      IMov THE_ITEM, HERE
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

MenuHandler HNDL_LINK
  ACTION:
    ;lda #4
    ;jsr here_advance_a
    jsr here_deref 
    ;jsr here_read_item
    jmp go_to_here
EndMenuHandler


.macro MenuLink title, id
  MenuItem HNDL_LINK, title
  .addr id
.endmacro



MenuHandler HNDL_BACK_LINK
  ACTION:
    jmp go_back 
EndMenuHandler


.macro MenuBackLink title
  .ifnblank title
    MenuItem HNDL_BACK_LINK, title
  .else
    MenuItem HNDL_BACK_LINK, "Go Back "
  .endif
.endmacro

.proc print_z_title
  jmp print_z_from_here
  rts
.endproc