MenuHandler HNDL_ECHO
  ACTION:
    jsr print::reset 
    jsr print_z_title
    jsr print::clear_rest
    wait:
      jsr GETIN
    beq wait
    rts
EndMenuHandler


.macro MenuEcho title
  MenuItem HNDL_ECHO, title
.endmacro