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
      jsr print::char
      lda first_two+1,y
      jsr print::char
    pla
    tax
    lda instr2,x
    pha 
      and #$0F
      tay
      lda last_one,y
      jsr print::char
      jsr print::space
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

    ColorSet 7
    rewrite:
    jsr $FEDA
    jmp print::nl
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
      jsr print::char
      lda #'B'
      jsr print::char
      lda #'Y'
      jsr print::char
      jsr print::space
      pla
      ColorSet 15
      jsr dump_sbyte
      jmp print::nl
  .endproc

  .proc print_open
    ColorSet 12
    lda #'('
    jmp print::char
  .endproc
  .proc print_close
    ColorSet 12
    lda #')'
    jmp print::char
  .endproc
  .proc print_x
    ColorSet 12
    lda #','
    jsr print::char
    lda #'X'
    jmp print::char
  .endproc
  .proc print_y
    ColorSet 12
    lda #','
    jsr print::char
    lda #'Y'
    jmp print::char
  .endproc
  
  .proc do_AC
    rts
    lda #'A'
    jmp print::char
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
    jsr print::char
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
    jsr print::char

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
    jsr print::byte_a
    pla
    jmp print::byte_a
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
 
  MIS = $C0
  INV = $FF  ; %r#(wbx)y
  _AC = $00  ; %00000000 
  _AB = $10  ; %00010000
  _AX = $20  ; %00010100
  _AY = $30  ; %00010001
  _HA = $40  ; %01000000
  _IM = $50  ; %00000000
  _IN = $60  ; %00110010
  _IY = $70  ; %00101011
  _XI = $80  ; %00101110
  _RE = $90  ; %10000000 
  _ZP = $A0  ; %00001000
  _ZX = $B0  ; %00001100  
  _ZY = $C0  ; %00001001

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
    .byte _K_ | _IM, _A_ | _XI, INV | INV, MIS, INV | INV, _A_ | _ZP, _L_ | _ZP, MIS
    .byte _P_ | _IM, _A_ | _HA, _L_ | _AC, MIS, INV | INV, _A_ | _AB, _L_ | _AB, MIS
    .byte _L_ | _RE, _A_ | _IY, INV | INV, MIS, INV | INV, _A_ | _ZX, _L_ | _ZX, MIS
    .byte _C_ | _IM, _A_ | _AY, INV | INV, MIS, INV | INV, _A_ | _AX, _L_ | _AX, MIS
    .byte _R_ + _AB, _D_ | _XI, INV | INV, MIS, _T_ | _ZP, _D_ | _ZP, _L_ | _ZP, MIS
    .byte _P_ | _IM, _D_ | _HA, _L_ | _AC, MIS, _T_ | _AB, _D_ | _AB, _L_ | _AB, MIS
    .byte _I_ | _RE, _D_ | _IY, INV | INV, MIS, INV | INV, _D_ | _ZX, _L_ | _ZX, MIS
    .byte _C_ | _IM, _D_ | _AY, INV | INV, MIS, INV | INV, _D_ | _AX, _L_ | _AX, MIS
    .byte _I_ | _IM, _R_ | _XI, INV | INV, MIS, INV | INV, _R_ | _ZP, _R_ | _ZP, MIS
    .byte _A_ | _IM, _R_ | _HA, _R_ | _AC, MIS, _P_ | _AB, _R_ | _AB, _R_ | _AB, MIS
    .byte _C_ | _RE, _R_ | _IY, INV | INV, MIS, INV | INV, _R_ | _ZX, _R_ | _ZX, MIS
    .byte _I_ | _IM, _R_ | _AY, INV | INV, MIS, INV | INV, _R_ | _AX, _R_ | _AX, MIS
    .byte _S_ | _IM, _C_ | _XI, INV | INV, MIS, INV | INV, _C_ | _ZP, _R_ | _ZP, MIS
    .byte _A_ | _IM, _C_ | _HA, _R_ | _AC, MIS, _P_ | _IN, _C_ | _AB, _R_ | _AB, MIS
    .byte _S_ | _RE, _C_ | _IY, INV | INV, MIS, INV | INV, _C_ | _ZX, _R_ | _ZX, MIS
    .byte _I_ | _IM, _C_ | _AY, INV | INV, MIS, INV | INV, _C_ | _AX, _R_ | _AX, MIS
    .byte INV | INV, _A_ | _XI, INV | INV, MIS, _Y_ | _ZP, _A_ | _ZP, _X_ | _ZP, MIS
    .byte _Y_ | _IM, INV | INV, _A_ | _IM, MIS, _Y_ | _AB, _A_ | _AB, _X_ | _AB, MIS
    .byte _C_ | _RE, _A_ | _IY, INV | INV, MIS, _Y_ | _ZX, _A_ | _ZX, _X_ | _ZY, MIS
    .byte _A_ | _IM, _A_ | _AY, _S_ | _IM, MIS, INV | INV, _A_ | _AX, INV | INV, MIS
    .byte _Y_ | _HA, _A_ | _XI, _X_ | _HA, MIS, _Y_ | _ZP, _A_ | _ZP, _X_ | _ZP, MIS
    .byte _Y_ | _IM, _A_ | _HA, _X_ | _IM, MIS, _Y_ | _AB, _A_ | _AB, _X_ | _AB, MIS
    .byte _S_ | _RE, _A_ | _IY, INV | INV, MIS, _Y_ | _ZX, _A_ | _ZX, _X_ | _ZY, MIS
    .byte _V_ | _IM, _A_ | _AY, _X_ | _IM, MIS, _Y_ | _AX, _A_ | _AX, _X_ | _AY, MIS
    .byte _Y_ | _HA, _P_ | _XI, INV | INV, MIS, _Y_ | _ZP, _P_ | _ZP, _C_ | _ZP, MIS
    .byte _Y_ | _IM, _P_ | _HA, _X_ | _IM, MIS, _Y_ | _AB, _P_ | _AB, _C_ | _AB, MIS
    .byte _E_ | _RE, _P_ | _IY, INV | INV, MIS, INV | INV, _P_ | _ZX, _C_ | _ZX, MIS
    .byte _D_ | _IM, _P_ | _AY, INV | INV, MIS, INV | INV, _P_ | _AX, _C_ | _AX, MIS
    .byte _X_ | _HA, _C_ | _XI, INV | INV, MIS, _X_ | _ZP, _C_ | _ZP, _C_ | _ZP, MIS
    .byte _X_ | _IM, _C_ | _HA, _P_ | _IM, MIS, _X_ | _AB, _C_ | _AB, _C_ | _AB, MIS
    .byte _Q_ | _RE, _C_ | _IY, INV | INV, MIS, INV | INV, _C_ | _ZX, _C_ | _ZX, MIS
    .byte _D_ | _IM, _C_ | _AY, INV | INV, MIS, INV | INV, _C_ | _AX, _C_ | _AX, MIS
  ;end

/*

; -----------------------------------------------------------------------------
; addressing mode table - nybbles provide index into MODE2 table
; for opcodes XXXXXXY0, use XXXXXX as index into table
; for opcodes WWWXXY01  use $40 + XX as index into table
; use right nybble if Y=0; use left nybble if Y=1

MODE    .BYTE $40,$02,$45,$03   ; even opcodes
        .BYTE $D0,$08,$40,$09
        .BYTE $30,$22,$45,$33
        .BYTE $D0,$08,$40,$09
        .BYTE $40,$02,$45,$33
        .BYTE $D0,$08,$40,$09
        .BYTE $40,$02,$45,$B3
        .BYTE $D0,$08,$40,$09
        .BYTE $00,$22,$44,$33
        .BYTE $D0,$8C,$44,$00
        .BYTE $11,$22,$44,$33
        .BYTE $D0,$8C,$44,$9A
        .BYTE $10,$22,$44,$33
        .BYTE $D0,$08,$40,$09
        .BYTE $10,$22,$44,$33
        .BYTE $D0,$08,$40,$09
        .BYTE $62,$13,$78,$A9   ; opcodes ending in 01

; addressing mode format definitions indexed by nybbles from MODE table

; left 6 bits define which characters appear in the assembly operand
; left 3 bits are before the address; next 3 bits are after

; right-most 2 bits define length of binary operand

; index               654 321
; 1st character       $(# ,),  
; 2nd character        $$ X Y    length  format      idx mode
MODE2   .BYTE $00   ; 000 000    00                  0   error
        .BYTE $21   ; 001 000    01      #$00        1   immediate
        .BYTE $81   ; 100 000    01      $00         2   zero-page
        .BYTE $82   ; 100 000    10      $0000       3   absolute
        .BYTE $00   ; 000 000    00                  4   implied
        .BYTE $00   ; 000 000    00                  5   accumulator
        .BYTE $59   ; 010 110    01      ($00,X)     6   indirect,X
        .BYTE $4D   ; 010 011    01      ($00),Y     7   indirect,Y
        .BYTE $91   ; 100 100    01      $00,X       8   zero-page,X
        .BYTE $92   ; 100 100    10      $0000,X     9   absolute,X
        .BYTE $86   ; 100 001    10      $0000,Y     A   absolute,Y
        .BYTE $4A   ; 010 010    10      ($0000)     B   indirect
        .BYTE $85   ; 100 001    01      $00,Y       C   zero-page,Y
        .BYTE $9D   ; 100 111    01      $0000*      D   relative
; * relative is special-cased so format bits don't match
; character lookup tables for the format definitions in MODE2
CHAR1   .BYTE $2C,$29,$2C       ; ","  ")"  ","
        .BYTE $23,$28,$24       ; "#"  "("  "$"

CHAR2   .BYTE $59,$00,$58       ; "Y"   0   "X"
        .BYTE $24,$24,$00       ; "$"  "$"   0
*/
.endscope
