MenuHandler HNDL_MENU
  ACTION:
    jmp go_to_the_item
  ITEMS:
    ldxy HERE
    jmp there_write_xy
EndMenuHandler

MenuHandler HNDL_LINK
  ACTION:
    ;lda #4
    ;jsr here_advance_a
    ldxy HERE
    goxy
    jmp go_to_xy
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
      __next_item__: .addr 0
    .endscope
  .endscope
.endmacro

.macro MenuRoot title
  Menu title, MENU_ROOT
.endmacro
