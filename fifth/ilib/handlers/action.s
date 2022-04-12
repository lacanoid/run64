MenuHandler HNDL_ACTION
  ACTION:
    jmp (HERE)
EndMenuHandler


.macro MenuAction title
  MenuItem HNDL_ACTION, title
.endmacro