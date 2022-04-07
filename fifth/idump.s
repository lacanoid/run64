.feature c_comments
jmp idump

.ifdef __C128__
  .include "defs128.inc"
.else
  .include "defs64.inc"
.endif
.include "macros/index.s"
.include "dis.s"
 
DP = $FB
PP = $FD
CP = $20

MODES = 6

.data
  CMODE: .byte 1
  HOME: .word $0000
  title: .asciiz "IDMP  M"
  rest: .byte 40
  line_cnt: .byte 0
  CP_TMP: .word 0
  char_mask: .byte $0
  
  MODE_PTR: .word MODES_TABLE+8

  MODES_TABLE:
  .word dis::print_instruction 
  .byte "DIS" 
  .res 3
  .word print_line_hex
  .byte "DEF"
  .res 3
  .word print_line_bytes
  .byte "BYT"
  .res 3
  .word print_line_mixed
  .byte "MIX"
  .res 3
  .word print_line_words
  .byte "WRD"
  .res 3
  .word print_line_text
  .byte "TXT"
  .res 3
.code

.proc idump
  IMov CP_TMP, CP
  ClearScreen
  PrintChr 14
  ISet 53280,0

  ::main_loop:
  loop:

  .proc set_mode 
    ISet MODE_PTR, MODES_TABLE
    lda CMODE
    clc
    asl 
    asl 
    asl
    IAddA MODE_PTR
  .endproc
    CSet COLOR,1
    ISet CP, COLORAM
    ISet PP, VICSCN
    ISet DP, title
    CSet char_mask, $80
    jsr print_z
    lda CMODE
    jsr print_hex_digit

    jsr print_space

    IMov DP, MODE_PTR
    IAddB DP, 2 
    jsr dump_char
    jsr dump_char
    jsr dump_char

    jsr print_nl
    CSet char_mask, $0
    

    IMov DP, HOME
    CSet line_cnt, 24
    CSet rest, 40
    line:
      jsr print_line
      dec line_cnt
    bne line

    wait: 
      jsr GETIN
    beq wait

    BraLt #'0', not_digit
    BraGe #'0'+MODES, not_digit
    sec 
    sbc #'0'
    sta CMODE
    jmp main_loop
    not_digit:
    BraEq #$3,exit 
    BraEq #$91,up 
    BraEq #$9d,left 
    BraEq #$11,down 
    BraEq #$1d,right 
    and #$7F
    BraEq #'q',exit
    BraEq #'m',mode
    BraEq #'w',up 
    BraEq #'s',down 
    BraEq #'a',sub_1
    BraEq #'d',add_1 
    bra wait
    up:
      jmp key_up
    down:
      jmp key_down
    left:
      jmp key_left
    right: 
      jmp key_right
    add_1:
      jmp key_add_1
    sub_1: 
      jmp key_sub_1
    mode:
      jmp key_mode
  exit:
    IMov CP, CP_TMP
    ClearScreen
  rts
.endproc

.proc key_up
  ISubB HOME, $80
  jmp main_loop
.endproc 

.proc key_down
  IAddB HOME, $80
  jmp main_loop
.endproc   
.proc key_left
  ISubB HOME+1, $10
  jmp main_loop
.endproc 
.proc key_right 
  IAddB HOME+1, $10
  jmp main_loop
.endproc 

.proc key_mode
  inc CMODE
  lda CMODE
  cmp #MODES
  bcc skip
    lda #0
    sta CMODE
  skip:
    jmp main_loop
.endproc

.proc key_sub_1
  ISubB HOME, $1
  jmp main_loop
.endproc 

.proc key_add_1
  IAddB HOME, $1
  jmp main_loop
.endproc   



.global print_space
.proc print_space
  pha
  lda #' '
  jsr print_char
  pla
  rts
.endproc

.global print_char
.proc print_char
  pha
  ora char_mask
  ldx #0
  sta (PP,x)
  lda COLOR
  sta (CP,X)
  jsr incPP
  pla
  rts 
.endproc

.proc reset_print
  ISet CP, COLORAM
  ISet PP, VICSCN
  CSet rest,40  
  rts
.endproc

.proc incPP
  inc CP
  inc PP
  bne skip
    inc CP+1
    inc PP+1
    lda PP+1
    cmp #8
    bne skip
    jsr reset_print
  skip:
  dec rest
  bne outro
    CSet rest,40  
  outro:
  rts
.endproc

.global print_nl
.proc print_nl
  loop: 
    lda rest
    cmp #40
    beq exit 
    jsr print_space
  bra loop
  exit:
  rts
.endproc


.proc incDP
  IInc DP
  rts
.endproc


.proc print_line

  ColorSet 1

  lda DP+1
  jsr print_hex_digits
  lda DP
  jsr print_hex_digits
  jsr print_space
  jsr print_space
  ColorSet 12
  IMov rewrite+1, MODE_PTR
  rewrite:
  jmp ($FADE)
 
.endproc
.proc choose_color
  IfTrue
    lda #1
  Else
    lda #15
  EndIf
  sta COLOR
  rts
.endproc
.proc print_line_hex
  .scope print_bytes
    ldy #4
    loop:
    tya
    and #$1
    jsr choose_color
    jsr dump_byte
    lda #':'
    jsr print_char
    jsr dump_byte
    jsr print_space
    dey 
    bne loop
    break:
  .endscope
  ISubB DP, 8
  jsr print_space
  ldy #4
  .scope print_chars
    loop:
      tya
      and #$1
      jsr choose_color
      sta COLOR
      jsr dump_char
      jsr dump_char
      dey
    bne loop
  .endscope
  exit:
    jmp print_nl
.endproc

.proc print_line_text
  ldy #32
  loop:
    jsr dump_char
    dey 
  bne loop
  jmp print_nl
.endproc


.proc print_line_words
  ldy #4
  loop:
    ColorSet 12
    jsr dump_word
    ColorSet 1
    jsr dump_word
    dey 
  bne loop
  jmp print_nl
.endproc

.proc print_line_bytes
  ldy #8
  loop:
    ColorSet 12
    jsr dump_byte
    ColorSet 1
    jsr dump_byte
    dey 
  bne loop
  jmp print_nl
.endproc

.proc print_line_mixed
  ldy #16
  loop:
    jsr read_data
    pha
    cmp #33
    bcc byte
    cmp #127
    bcs byte
      ColorSet 7
      pla 
      jsr print_char
      jsr print_space
      bra done
    byte:
      tya
      and #$1
      IfTrue 
        ColorSet 11
      Else 
        ColorSet 12
      EndIf
      ;CSet char_mask, $80
      pla 
      jsr print_hex_digits
      ;CSet char_mask, $0
    done:
    dey 
  bne loop
  jmp print_nl
.endproc

.global dump_sword
.proc dump_sword
  lda #'$'
  jsr print_char
  ;continue
.endproc
.proc dump_word
  jsr read_data
  pha
  jsr dump_byte
  pla
  jsr print_hex_digits
  rts
.endproc

.global dump_sbyte
.proc dump_sbyte
  lda #'$'
  jsr print_char
  ;continue
.endproc

.proc dump_byte
  jsr read_data
  jsr print_hex_digits
  rts
.endproc


.proc dump_char
  jsr read_data
  jmp print_char
.endproc


.global print_hex_digits
.proc print_hex_digits
  pha
  sec
  lsr 
  lsr 
  lsr 
  lsr
  jsr print_hex_digit
  pla

  pha
  and #$0f
  jsr print_hex_digit
  pla
  rts
.endproc

.proc print_hex_digit
  BraGe #10, big
    add #'0'
    jsr print_char
    rts
  big:
    add #'a'-10
    jsr print_char
    rts
.endproc

.proc print_z
  ldx #0
  loop:
    jsr read_data
    BraFalse exit
    jsr print_char
    bra loop
  exit:
    rts
.endproc

.global read_data
.proc read_data
  ReadA DP
  rts
.endproc
