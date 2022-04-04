jmp idump

.include "../defs64.inc"
.include "macros/index.s"
.include "../utils.s"
 
 mode: .byte 0
 CP: .word $0000
 DP = $FB
 PP = $FD 
 title: .asciiz "IDUMP 1.0"

.proc idump
  ClearScreen
  ISet 53280,0
  ISet DP, title
  ISet PP, 1024  
  jsr print_z
  PrintChr 14
  loop:
    jsr dump_hex

    CSet $CC, 0
    wait: 
      jsr GETIN
    beq wait
    
    and #$7F

    BraEq #'Q',exit
    IfEq #'W'
      ISubB CP, $80
      bra next
    EndIf
    IfEq #'S'
      IAddB CP, $80
      bra next
    EndIf
    IfEq #'A'
      ISubB CP+1, $10
      bra next
    EndIf
    IfEq #'D'
      IAddB CP+1,$10
      bra next
    EndIf
    bra wait
  next:
    ldx #16
  bra loop
  exit:
    ClearScreen
  rts
.endproc

.proc print_char
  sta (PP,x)
.endproc

.proc incPP
  IInc PP
  rts
.endproc

.proc incDP
  IInc DP
  rts
.endproc


.proc dump_hex
  ldx #0
  ldy #0
  clc
  jsr PLOT
  ISet PP, 1064
  IMov DP, CP
  jsr do_dump_hex
  jsr do_dump_hex
  ;continue
.endproc
.proc do_dump_hex
  ldy #128
  
  print_line:
    lda DP+1
    jsr print_hex_digits
    lda DP
    jsr print_hex_digits
    jsr incPP
    
    .scope print_bytes
      loop:
      tya
      and #1
      bne colon
        jsr incPP
        bra space
      colon:
        lda #':'
        jsr print_char
      space:        
      lda (DP,x)
      jsr print_hex_digits
      jsr incDP
      dey
      tya
      and #7
      bne loop
      break:
    .endscope
    ISubB DP, 8
    jsr incPP
    .scope print_chars
      loop:
        tya
        and #3
        bne skip
          jsr incPP
        skip: 
        lda (DP,x)
        jsr print_char
        jsr incDP
        dey
        tya
        and #7
        bne loop
      break:
  .endscope
  next_line:
  tya
  BraFalse exit
  jmp print_line
  exit:
    rts
.endproc



  .proc print_hex_digits
    pha
    sec
    lsr 
    lsr 
    lsr 
    lsr
    jsr print_hex_digit

    pla
    and #$0f
    ;continue
  .endproc

  .proc print_hex_digit
    BraGe #10, big
      add #'0'
      jsr print_char
      rts
    big:
      add #'A'-10
      jsr print_char
      rts
  .endproc

 .proc print_z
    ldx #0
    loop:
      lda (DP,x)
      BraFalse exit
      jsr print_char
      jsr incDP
      bra loop
    exit:
      rts
  .endproc
  
MSGBAS: