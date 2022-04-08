.include "defs-auto.inc"
.include "macros/basics.s"
.include "imenu_lib/print.s"

.macro ColorSet c
    lda #c 
    sta COLOR
.endmacro

.scope idump
  .include "dis.s"  
  DP = $FB
  MODES = 6
  .data
    CMODE: .byte 1
    HOME: .word $0000
    title: .asciiz "IDMP  M"
    rest: .byte 40
    line_cnt: .byte 0
    DP_TMP: .word 0
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


  ::idump_main:
  .proc main
    IMov DP_TMP, DP
    lda #14
    jsr CHROUT
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
      jsr print::reset
      jsr print::rev_on
      ISet DP, title
      jsr print_z
      lda CMODE
      jsr print::nybble_a

      jsr print::space

      IMov DP, MODE_PTR
      IAddB DP, 2 
      jsr dump_char
      jsr dump_char
      jsr dump_char

      jsr print::nl
      jsr print::rev_off
      

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
      JmpEq #$91,key_up
      JmpEq #$9d,key_left 
      JmpEq #$11,key_down 
      JmpEq #$1d,key_right 
      and #$7F
      BraEq #'q',exit
      JmpEq #'m',key_mode
      JmpEq #'w',key_up 
      JmpEq #'s',key_down 
      JmpEq #'a',key_sub_1
      JmpEq #'d',key_add_1 
      bra wait
    exit:
      IMov DP, DP_TMP
      lda #147
      jsr CHROUT 
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

  .proc print_line
    ColorSet 1
    ldy DP+1
    lda DP
    jsr print::word_ay
    jsr print::space
    jsr print::space
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
      jsr print::char
      jsr dump_byte
      jsr print::space
      dey 
      bne loop
      break:
    .endscope
    ISubB DP, 8
    jsr print::space
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
      jmp print::nl
  .endproc

  .proc print_line_text
    ldy #32
    loop:
      jsr dump_char
      dey 
    bne loop
    jmp print::nl
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
    jmp print::nl
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
    jmp print::nl
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
        jsr print::char
        jsr print::space
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
        jsr print::byte_a
        ;CSet char_mask, $0
      done:
      dey 
    bne loop
    jmp print::nl
  .endproc

  .global dump_sword
  .proc dump_sword
    lda #'$'
    jsr print::char
    ;continue
  .endproc
  .proc dump_word
    jsr read_data
    pha
    jsr dump_byte
    pla
    jsr print::byte_a
    rts
  .endproc

  .global dump_sbyte
  .proc dump_sbyte
    lda #'$'
    jsr print::char
    ;continue
  .endproc

  .proc dump_byte
    jsr read_data
    jsr print::byte_a
    rts
  .endproc


  .proc dump_char
    jsr read_data
    jmp print::char
  .endproc

  .proc print_z
    ldx #0
    loop:
      jsr read_data
      BraFalse exit
      jsr print::char
      bra loop
    exit:
      rts
  .endproc

  .global read_data
  .proc read_data
    ReadA DP
    rts
  .endproc


.endscope