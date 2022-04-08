.enum METHODS
  PRINT=0
  ACTION=2
  ITEMS=4
  BACK=6
.endenum

.macro MenuHandler arg
  .align 2
  ::arg:
  .scope arg 
    .word __print__
    .word __action__
    .word __items__
    .word __back__
.endmacro
.macro EndMenuHandler
    .ifdef PRINT
      __print__ = PRINT
    .else
      __print__ = print_z_title
    .endif
    .ifdef ACTION
      __action__ = ACTION
    .else
      __action__ = 0
    .endif
    .ifdef ITEMS
      __items__ = ITEMS
    .else
      __items__ = 0
    .endif
    .ifdef BACK
      __back__ = BACK
    .else
      __back__ = 0
    .endif
  .endscope
.endmacro


.macro Menu title, id
  .ifnblank id 
    ::id:
  .endif
  .scope
    .addr HNDL_MENU
    .data
        __title__: 
        .byte title, 0
    .code
    .addr __title__
    .scope 
.endmacro

.macro MenuItem handler, title
      __next_item__:
    .endscope
    .scope 
      .addr __next_item__
    __item__:
      .addr handler
      .data
        __title__: 
        .byte title, 0
      .code
      .addr __title__
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
