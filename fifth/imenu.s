jmp MAIN
.include "imenu_lib/core.s"
.include "imenu_lib/idump.s"
MAIN = imenu::main

MenuRoot "Home"
  MenuHeading "This is the root menu"
  MenuAction "dump items"
    ISet idump::HOME, imenu::MENU_ITEMS
    jmp idump::main
  MenuAction "dump heap"
    ISet idump::HOME, $C000
    jmp idump::main
  MenuAction "idump"
    jmp idump::main
  MenuDirectory "ls"
  MenuSub "Border"
    MenuAction "white"
      lda #1
      sta 53280
      rts
    MenuAction "red"
      lda #2
      sta 53280
      rts 
    MenuAction "blue"
      lda #3
      sta 53280
      rts
    MenuBackLink
  EndMenuSub 
EndMenu

