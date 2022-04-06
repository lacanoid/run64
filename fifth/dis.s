.macro FirstTwo arg1
  .local here
  here:
  .ident(.concat(arg1,"_")) = here - first_two
  .byte arg1
.endmacro
.macro LastOne arg1
  .local here
  here:
  .ident(.concat("_",arg1,"_")) = here - last_one
  .byte arg1
.endmacro

.scope dis
  .proc print_instruction
    ColorSet 14
    jsr read_data
    pha
      tax
      ldy instr1,x
      cpy #INV
      beq invalid
      tya
      lda first_two,y
      jsr print_char
      lda first_two+1,y
      jsr print_char
    pla
    tax
    lda instr2,x
    pha 
      and #$0F
      tay
      lda last_one,y
      jsr print_char
      jsr print_space
    pla 
    
    
    and #$f0
    
    clc
    lsr
    lsr
    lsr
    tay
    
    lda table+1,y
    sta rewrite+2

    lda table,y
    sta rewrite+1
    ;jsr print_hex_digits

    ;jsr print_space
    ;tya
    ;lsr
    ;jsr print_hex_digits
    ColorSet 7
    rewrite:
    jsr $FEDA
    jmp print_nl
    .data
    table: 
    .word do_AC 
    .word do_AB 
    .word do_AX 
    .word do_AY 
    .word do_HA 
    .word do_IM 
    .word do_IN 
    .word do_IY 
    .word do_XI 
    .word do_RE 
    .word do_ZP 
    .word do_ZX 
    .word do_ZY 
    .code
    invalid:
      ColorSet 4
      lda #'.'
      jsr print_char
      lda #'B'
      jsr print_char
      lda #'Y'
      jsr print_char
      jsr print_space
      pla
      ColorSet 15
      jsr dump_sbyte
      jmp print_nl
  .endproc

  .proc print_open
    ColorSet 12
    lda #'('
    jmp print_char
  .endproc
  .proc print_close
    ColorSet 12
    lda #')'
    jmp print_char
  .endproc
  .proc print_x
    ColorSet 12
    lda #','
    jsr print_char
    lda #'X'
    jmp print_char
  .endproc
  .proc print_y
    ColorSet 12
    lda #','
    jsr print_char
    lda #'Y'
    jmp print_char
  .endproc
  
  .proc do_AC
    rts
    lda #'A'
    jmp print_char
  .endproc

  .proc do_AB

    jmp dump_sword
  .endproc
  .proc do_AX
    jsr dump_sword
    jmp print_x 
  .endproc
  .proc do_AY
    jsr dump_sword
    jmp print_y
  .endproc
  .proc do_HA
    ColorSet 8
    lda #'#'
    jsr print_char
    jmp dump_sbyte
  .endproc
  .proc do_IM
    rts
  .endproc
  .proc do_IN
    jsr print_open
    ColorSet 7
    jsr dump_sword
    jmp print_close
  .endproc
  .proc do_IY
    jsr print_open
    ColorSet 7
    jsr dump_sbyte
    jsr print_close
    jmp print_y
  .endproc
  .proc do_XI
    jsr print_open
    ColorSet 7
    jsr dump_sbyte
    jsr print_x
    jmp print_close
  .endproc
  .proc do_RE 
    lda #'$'
    jsr print_char

    ldy #$00
    jsr read_data
    bpl skip
      dey        ; decrement high byte to $ff for a negative delta
    skip:
    clc
    adc DP   ; .A still holds delta
    pha 
    tya         ; .X is the high byte
    adc DP+1
    ColorSet 7
    jsr print_hex_digits
    pla
    jmp print_hex_digits
  .endproc
  .proc do_ZP
    ColorSet 7
    jmp dump_sbyte
  .endproc
  .proc do_ZX
    ColorSet 7
    jsr dump_sbyte
    jmp print_x
  .endproc
  .proc do_ZY
    ColorSet 7
    jsr dump_sbyte
    jmp print_y
  .endproc
 

  INV = $FF
  _AC = $00
  _AB = $10
  _AX = $20
  _AY = $30
  _HA = $40
  _IM = $50
  _IN = $60
  _IY = $70
  _XI = $80
  _RE = $90
  _ZP = $A0
  _ZX = $B0
  _ZY = $C0

.align 2
first_two:
  FirstTwo "AD"
  FirstTwo "AN"
  FirstTwo "AS"

  FirstTwo "BC"
  FirstTwo "BE"
  FirstTwo "BN"
  FirstTwo "BI"
  FirstTwo "BM"
  FirstTwo "BP"
  FirstTwo "BR"
  FirstTwo "BV"

  FirstTwo "CL"
  FirstTwo "CM"
  FirstTwo "CP"

  FirstTwo "DE"

  FirstTwo "EO"

  FirstTwo "IN"

  FirstTwo "JM"
  FirstTwo "JS"

  FirstTwo "LD"
  FirstTwo "LS"

  FirstTwo "NO"

  FirstTwo "OR"

  FirstTwo "PH"
  FirstTwo "PL"

  FirstTwo "RO"
  FirstTwo "RT"

  FirstTwo "SB"
  FirstTwo "SE"
  FirstTwo "ST"

  FirstTwo "TX"
  FirstTwo "TA"
  FirstTwo "TS"
  FirstTwo "TY"
;end 
.align 2
last_one:
  LastOne "K"
  LastOne "A"
  LastOne "L"
  LastOne "P"
  LastOne "C"
  LastOne "R"
  LastOne "D"
  LastOne "T"
  LastOne "I"
  LastOne "S"
  LastOne "Y"
  LastOne "X"
  LastOne "V"
  LastOne "E"
  LastOne "Q"
;end

  .align 2
  instr1:
    .byte BR_, OR_, INV, INV, INV, OR_, AS_, INV, PH_, OR_, AS_, INV, INV, OR_, AS_, INV
    .byte BP_, OR_, INV, INV, INV, OR_, AS_, INV, CL_, OR_, INV, INV, INV, OR_, AS_, INV 
    .byte JS_, AN_, INV, INV, BI_, AN_, RO_, INV, PL_, AN_, RO_, INV, BI_, AN_, RO_, INV
    .byte BM_, AN_, INV, INV, INV, AN_, RO_, INV, SE_, AN_, INV, INV, INV, AN_, RO_, INV 
    .byte RT_, EO_, INV, INV, INV, EO_, LS_, INV, PH_, EO_, LS_, INV, JM_, EO_, LS_, INV 
    .byte BV_, EO_, INV, INV, INV, EO_, LS_, INV, CL_, EO_, INV, INV, INV, EO_, LS_, INV 
    .byte RT_, AD_, INV, INV, INV, AD_, RO_, INV, PL_, AD_, RO_, INV, JM_, AD_, RO_, INV 
    .byte BV_, AD_, INV, INV, INV, AD_, RO_, INV, SE_, AD_, INV, INV, INV, AD_, RO_, INV 
    .byte INV, ST_, INV, INV, ST_, ST_, ST_, INV, DE_, INV, TX_, INV, ST_, ST_, ST_, INV 
    .byte BC_, ST_, INV, INV, ST_, ST_, ST_, INV, TY_, ST_, TX_, INV, INV, ST_, INV, INV 
    .byte LD_, LD_, LD_, INV, LD_, LD_, LD_, INV, TA_, LD_, TA_, INV, LD_, LD_, LD_, INV 
    .byte BC_, LD_, INV, INV, LD_, LD_, LD_, INV, CL_, LD_, TS_, INV, LD_, LD_, LD_, INV 
    .byte CP_, CM_, INV, INV, CP_, CM_, DE_, INV, IN_, CM_, DE_, INV, CP_, CM_, DE_, INV 
    .byte BN_, CM_, INV, INV, INV, CM_, DE_, INV, CL_, CM_, INV, INV, INV, CM_, DE_, INV 
    .byte CP_, SB_, INV, INV, CP_, SB_, IN_, INV, IN_, SB_, NO_, INV, CP_, SB_, IN_, INV 
    .byte BE_, SB_, INV, INV, INV, SB_, IN_, INV, SE_, SB_, INV, INV, INV, SB_, IN_, INV
  ; end

  instr2:
    .byte _K_ | _IM, _A_ | _XI, INV | INV, INV | INV, INV | INV, _A_ | _ZP, _L_ | _ZP, INV | INV
    .byte _P_ | _IM, _A_ | _HA, _L_ | _AC, INV | INV, INV | INV, _A_ | _AB, _L_ | _AB, INV | INV
   
    .byte _L_ | _RE, _A_ | _IY, INV | INV, INV | INV, INV | INV, _A_ | _ZX, _L_ | _ZX, INV | INV
    .byte _C_ | _IM, _A_ | _AY, INV | INV, INV | INV, INV | INV, _A_ | _AX, _L_ | _AX, INV | INV
    
    .byte _R_ + _AB, _D_ | _XI, INV | INV, INV | INV, _T_ | _ZP, _D_ | _ZP, _L_ | _ZP, INV | INV
    .byte _P_ | _IM, _D_ | _HA, _L_ | _AC, INV | INV, _T_ | _AB, _D_ | _AB, _L_ | _AB, INV | INV
   
    .byte _I_ | _RE, _D_ | _IY, INV | INV, INV | INV, INV | INV, _D_ | _ZX, _L_ | _ZX, INV | INV
    .byte _C_ | _IM, _D_ | _AY, INV | INV, INV | INV, INV | INV, _D_ | _AX, _L_ | _AX, INV | INV
    
    .byte _I_ | _IM, _R_ | _XI, INV | INV, INV | INV, INV | INV, _R_ | _ZP, _R_ | _ZP, INV | INV
    .byte _A_ | _IM, _R_ | _HA, _R_ | _AC, INV | INV, _P_ | _AB, _R_ | _AB, _R_ | _AB, INV | INV
    .byte _C_ | _RE, _R_ | _IY, INV | INV, INV | INV, INV | INV, _R_ | _ZX, _R_ | _ZX, INV | INV
    .byte _I_ | _IM, _R_ | _AY, INV | INV, INV | INV, INV | INV, _R_ | _AX, _R_ | _AX, INV | INV
    
    .byte _S_ | _IM, _C_ | _XI, INV | INV, INV | INV, INV | INV, _C_ | _ZP, _R_ | _ZP, INV | INV
    .byte _A_ | _IM, _C_ | _HA, _R_ | _AC, INV | INV, _P_ | _IN, _C_ | _AB, _R_ | _AB, INV | INV
    .byte _S_ | _RE, _C_ | _IY, INV | INV, INV | INV, INV | INV, _C_ | _ZX, _R_ | _ZX, INV | INV
    .byte _I_ | _IM, _C_ | _AY, INV | INV, INV | INV, INV | INV, _C_ | _AX, _R_ | _AX, INV | INV
    
    .byte INV | INV, _A_ | _XI, INV | INV, INV | INV, _Y_ | _ZP, _A_ | _ZP, _X_ | _ZP, INV | INV
    .byte _Y_ | _IM, INV | INV, _A_ | _IM, INV | INV, _Y_ | _AB, _A_ | _AB, _X_ | _AB, INV | INV
    .byte _C_ | _RE, _A_ | _IY, INV | INV, INV | INV, _Y_ | _ZX, _A_ | _ZX, _X_ | _ZY, INV | INV
    .byte _A_ | _IM, _A_ | _AY, _S_ | _IM, INV | INV, INV | INV, _A_ | _AX, INV | INV, INV | INV
    
    .byte _Y_ | _HA, _A_ | _XI, _X_ | _HA, INV | INV, _Y_ | _ZP, _A_ | _ZP, _X_ | _ZP, INV | INV
    .byte _Y_ | _IM, _A_ | _HA, _X_ | _IM, INV | INV, _Y_ | _AB, _A_ | _AB, _X_ | _AB, INV | INV
    .byte _S_ | _RE, _A_ | _IY, INV | INV, INV | INV, _Y_ | _ZX, _A_ | _ZX, _X_ | _ZY, INV | INV
    .byte _V_ | _IM, _A_ | _AY, _X_ | _IM, INV | INV, _Y_ | _AX, _A_ | _AX, _X_ | _AY, INV | INV
    
    .byte _Y_ | _HA, _P_ | _XI, INV | INV, INV | INV, _Y_ | _ZP, _P_ | _ZP, _C_ | _ZP, INV | INV
    .byte _Y_ | _IM, _P_ | _HA, _X_ | _IM, INV | INV, _Y_ | _AB, _P_ | _AB, _C_ | _AB, INV | INV
    .byte _E_ | _RE, _P_ | _IY, INV | INV, INV | INV, INV | INV, _P_ | _ZX, _C_ | _ZX, INV | INV
    .byte _D_ | _IM, _P_ | _AY, INV | INV, INV | INV, INV | INV, _P_ | _AX, _C_ | _AX, INV | INV
    
    .byte _X_ | _HA, _C_ | _XI, INV | INV, INV | INV, _X_ | _ZP, _C_ | _ZP, _C_ | _ZP, INV | INV
    .byte _X_ | _IM, _C_ | _HA, _P_ | _IM, INV | INV, _X_ | _AB, _C_ | _AB, _C_ | _AB, INV | INV
    .byte _Q_ | _RE, _C_ | _IY, INV | INV, INV | INV, INV | INV, _C_ | _ZX, _C_ | _ZX, INV | INV
    .byte _D_ | _IM, _C_ | _AY, INV | INV, INV | INV, INV | INV, _C_ | _AX, _C_ | _AX, INV | INV
  ;end

.endscope