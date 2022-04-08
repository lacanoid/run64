
Menu "Home", MENU_ROOT
  MenuHeading "This is the root menu"
  MenuEcho "echo me"
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

