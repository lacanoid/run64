MenuHandler HNDL_ECHO
  ACTION:
    ;ClearScreen
    jsr print_nl
    jsr print_z_title
    
    wait:
      jsr GETIN
    beq wait
    rts
EndMenuHandler


.macro MenuEcho title
  MenuItem HNDL_ECHO, title
.endmacro