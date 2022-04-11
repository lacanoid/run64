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
      IAddB HERE,2
      jsr add_item_here
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

.macro Menu title, id
  .ifnblank id 
    ::id:
  .endif
  .scope
    .addr HNDL_MENU
    .byte .strlen(title)+1
    .byte title, 0
    .scope 
.endmacro

.macro MenuItem handler, title
      __next_item__:
    .endscope
    .scope 
      .addr __next_item__
    __item__:
      .addr handler
      .byte .strlen(title)+1
      .byte title, 0
.endmacro

.macro MenuSub title, id
      __next_item__:
    .endscope
    .scope 
      .addr __next_item__
      Menu title,id
.endmacro


.macro EndMenuSub
  EndMenu
.endmacro

.macro EndMenu
      __next_item__ = 0
    .endscope
  .endscope
.endmacro

.macro MenuRoot title
  Menu title, MENU_ROOT
.endmacro
