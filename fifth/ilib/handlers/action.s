MenuHandler HNDL_ACTION
  ACTION:
    jmp (HERE)
    wait:
      jsr GETIN
    beq wait
    rts
EndMenuHandler


.macro MenuAction title
  MenuItem HNDL_ACTION, title
.endmacro