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

