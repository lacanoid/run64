

MenuHandler HNDL_CUSTOM_ACTION
  ACTION:
    jmp (HERE)
EndMenuHandler


.macro MenuCustomAction title
  MenuItem HNDL_CUSTOM_ACTION, title
.endmacro


MenuHandler HNDL_ACTION
  ACTION:
    ldxy THE_ITEM
    jsr print_header_xy
    CSet COLOR, 0
    ldxy #$0100
    print set_tl 
    ldxy #$1828
    print set_wh 
    print reset
    ldxy HERE
    jsxy
    wait: jsr GETIN
    beq wait 
    print reset_window
    rts 
EndMenuHandler


.macro MenuAction title
  MenuItem HNDL_ACTION, title
.endmacro
