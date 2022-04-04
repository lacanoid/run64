jmp idump

.include "../defs64.inc"
.include "macros/index.s"
.include "../utils.s"
 
 MODE: .byte 0
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
  CSet $CC, 0
  ::main_loop:
  loop:
    lda MODE
    beq hex
      jsr dump_text
      bra wait
    hex:
      jsr dump_hex

    wait: 
      jsr GETIN
    beq wait
    
    BraEq #$91,up 
    BraEq #$9d,left 
    BraEq #$11,down 
    BraEq #$1d,right 
    and #$7F
    BraEq #'Q',exit
    BraEq #'M',mode
    BraEq #'W',up 
    BraEq #'S',down 
    BraEq #'A',left 
    BraEq #'D',right 
    bra wait
    up:
      jmp key_up
    down:
      jmp key_down
    left:
      jmp key_left
    right: 
      jmp key_right
    mode:
      jmp key_mode
  exit:
    ClearScreen
  rts
.endproc

.proc key_up
  ISubB CP, $80
  jmp main_loop
.endproc 

.proc key_down
  IAddB CP, $80
  jmp main_loop
.endproc   
.proc key_left
  ISubB CP+1, $10
  jmp main_loop
.endproc 
.proc key_right 
  IAddB CP+1, $10
  jmp main_loop
.endproc 
.proc key_mode
  lda MODE
  eor #$FF
  sta MODE
  jmp main_loop
.endproc

.proc print_space
  lda #' '
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
    jsr print_space
    
    .scope print_bytes
      loop:
      tya
      and #1
      bne colon
        jsr print_space
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
    jsr print_space
    .scope print_chars
      loop:
        tya
        and #3
        bne skip
          jsr print_space
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



.proc dump_text
  ldx #0
  ldy #0
  jsr PLOT
  ISet PP, 1064
  IMov DP, CP
  
  jsr do_dump_text
  jsr do_dump_text
  ;continue
.endproc

.proc do_dump_text
  ldy #0
  print_line:
    lda DP+1
    jsr print_hex_digits
    lda DP
    jsr print_hex_digits
    jsr print_space
    jsr print_space
    .scope print_chars
      loop:
        lda (DP,x)
        jsr print_char
        jsr incDP
        dey
        tya
        and #31
        bne loop
      break:
  .endscope
  next_line:
  jsr print_space 
  jsr print_space 
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