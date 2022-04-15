.feature c_comments
IMENU_INCLUDE_DIRECTORY = 0
jmp MAIN
.include "../imenu.s"
MAIN = imenu::main

MenuRoot "color scheme"
    MenuAction "default"
      CSet imenu::COLOR_BG ,imenu::DEF_BG 
      CSet imenu::COLOR_BRD,imenu::DEF_BRD
      CSet imenu::COLOR_FG ,imenu::DEF_FG 
      CSet imenu::COLOR_SEL,imenu::DEF_SEL
      CSet imenu::COLOR_HDR,imenu::DEF_HDR
      rts
    MenuAction "dark"
      CSet imenu::COLOR_BG ,0
      CSet imenu::COLOR_BRD,0
      CSet imenu::COLOR_FG ,12 
      CSet imenu::COLOR_SEL,15
      CSet imenu::COLOR_HDR,1
      rts 
EndMenu

