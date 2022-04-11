.include "defs-auto.inc"
.include "macros/basics.s"
.include "ilib/print.s"

.macro ColorSet c
    lda #c 
    sta COLOR
.endmacro

.macro signed arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8
  .ifnblank arg1 
    .if (arg1<0)
      .word ((-arg1 ^ $FFFF) + 1) & $FFFF
    .else
      .word arg1
    .endif
    .ifnblank arg2
      signed arg2, arg3, arg4, arg5, arg6, arg7, arg8
    .endif 
  .endif 
.endmacro

.scope idump
  .include "dis.s"  
  DP = $FB
  MODES = 6
  .data
    CMODE: .byte 1
    HOME: .word $0000
    TITLE: .asciiz "IDMP  M"
    DP_TMP: .word 0
    LINE_CNT: .word 0
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
    KEY_CODES:
      .byte $3, 'q', 'm'
      .byte 0
      .addr exit, exit, key_mode
    DKEY_CODES:
      .byte $91, $9d, $11, $1d
      .byte 'w', 'a', 's', 'd'
      .byte 0
      signed -$80, -$1000, $80, $1000 
      signed -$10, -$1, $10, $1
  .code



  ::idump_main:
  .proc main
    IMov DP_TMP, DP
    lda #14
    jsr CHROUT
    ISet 53280,0
    jsr set_mode
  .endproc
  .proc main_loop
    loop:
      jsr set_mode

      CSet COLOR,1
      jsr print::reset
      jsr print::rev_on
      ldx #<TITLE
      ldy #>TITLE 
      jsr print::z_at_xy

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
      CSet LINE_CNT, 24
      line:
        jsr print_line
        dec LINE_CNT
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
      ldxy #DKEY_CODES
      pha
      jsr lookup
      pla
      bcs not_dkey
      txa
      adc HOME
      sta HOME
      tya
      adc HOME+1
      sta HOME+1
      jmp main_loop
      
      not_dkey:
      ldxy #KEY_CODES
      
      jsr lookup

      bcs wait
      stx rwj+1
      sty rwj+2
      rwj: jmp $FADE 
      
    .endproc

  .proc set_mode 
    ISet MODE_PTR, MODES_TABLE
    lda CMODE
    clc
    asl 
    asl 
    asl
    IAddA MODE_PTR
    rts 
  .endproc
  
    
  .proc exit
    IMov DP, DP_TMP
    lda #147
    jsr CHROUT 
    rts
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



  .proc print_line
    ColorSet 1
    ldx DP
    ldy DP+1
    jsr print::word_xy
    jsr print::space
    jsr print::space
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

  .proc lookup
    stx rw+1
    sty rw+2
    sta rwa+1
    ldy #0
    find:
      jsr read
      beq not_found    ; if 0 terminator, give up
      rwa: cmp #00
      beq found        ; found, so don't advance y
      iny              
    bne find            ; if y rolls over, give up
    not_found:
      sec
      rts
    found:            ; y is at found char, double and store for later
      tya 
      clc
      asl 
      sta rwf+1
      
    skip:
      iny             ; start looking after the found char
      beq not_found   ; if y rolls over, give up
      jsr read
    bne skip
    tya               ; y is at 0 terminator byte, add the offset we stored earlier + 1
    sec 
    
    rwf: adc #00      
    tay               ; y is at the looked up word
    jsr read
    tax  
    iny
    jsr read
    tay
    clc
    rts 
    read:
    rw: lda $FEED,y
    rts
  .endproc      
 .endscope