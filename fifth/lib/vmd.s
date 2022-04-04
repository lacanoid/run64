; parameters:
; inst x       : register
; inst x, a    : register, another register
; inst x, a, y : register, lo byte, high byte




.scope VMI
  TMP = $2
  R = $20
  LO = $FB
  HI = $FD
  
  .scope REGS
    aa = 0
    bb = 2
    cc = 4
    dd = 6
    ee = 8
    ff = 10
    gg = 12
    hh = 14
    r0 = 16
    rp = 18
    s0 = 20
    sp = 22
    t0 = 24
    tp = 26
    u0 = 28
    up = 30
  .endscope
  
  .scope IREGS
    xa = 0
    xb = 2
    xc = 4
    xd = 6
    xe = 8
    xf = 10
    xg = 12
    xh = 14
    xr = 16
    xs = 20
    xt = 24
    xu = 28
  .endscope
  ; utils:
    .proc get_rx
      lda R,x
      ldy R+1,x
      rts
    .endproc
    
    .proc get_ry
      lda R,y
      pha
      lda R+1,y
      tay
      pla
      rts
    .endproc

    .proc set_rx
      sta R,x
      sty R+1,x
      rts
    .endproc

    .proc addr_set_ay
      sta LO
      sta HI
      sty LO+1
      sty HI+1
      inc HI
      bne skip
        inc HI+1
      skip:
      rts
    .endproc


    .proc addr_set_rx
      pha
      lda R,x
      sta LO
      sta HI
      lda R+1,x
      sta LO+1
      sta HI+1
      inc HI
      bne skip
        inc HI+1
      skip:
      pla
      rts
    .endproc
    
    .proc addr_set_ry
      pha
      lda R,y
      sta LO
      sta HI
      lda R+1,y
      sta LO+1
      sta HI+1
      inc HI
      bne skip
        inc HI+1
      skip:
      pla
      rts
    .endproc

     .proc read_from_addr
      ldy #0
      lda (LO),y
      pha
      lda (HI),y
      tay
      pla
      rts
    .endproc

    .proc write_to_addr
      stx TMP
      ldx #0
      sta (LO,x)
      pha
      tya
      sta (HI,x)
      pla
      ldx TMP
      rts
    .endproc
/*
    .proc save_rx
      jsr get_rx
      jmp write_to_addr
    .endproc

    .proc save_ry
      jsr get_ry
      jmp write_to_addr
      rts
    .endproc

    .proc load_rx
      jsr read_from_addr
      jmp set_rx
    .endproc
*/
    set_m = write_to_addr
    .proc get_m
      jsr addr_set_ay
      jmp read_from_addr
    .endproc

    .proc get_iy
      jsr addr_set_ry
      jmp read_from_addr
    .endproc
    .proc get_ix
      jsr addr_set_rx
      jmp read_from_addr
    .endproc


    .proc set_ix
      jsr addr_set_rx
      jmp write_to_addr
    .endproc

  ; MVI
    ; mvi aa, bb
    .proc mv_rx_ry
      jsr get_ry
      jmp set_rx
    .endproc

    ; mvi aa, xb
    .proc mv_rx_iy
      jsr get_iy
      jmp set_rx
    .endproc

    ; mvi xa, bb
    .proc mv_ix_ry
      jsr get_ry
      jmp set_ix
    .endproc

    ; mvi xa, bb
    .proc mv_ix_iy
      jsr get_iy
      jmp set_ix
    .endproc

 ; CPI

    .proc cp_x
      pha
      sec
      eor #$ff
      adc R,x
      php
      tya 
      eor #$ff
      adc R+1,x

      php
      pla
      sta TMP
      pla
      and #%00000010
      ora #%11111101
      and TMP 
      pha
      plp

      pla
      rts
    .endproc
    
    .proc cp_rx_w
      jmp cp_x
    .endproc

    .proc cp_rx_ry
      jsr get_ry
      jmp cp_x 
    .endproc

    .proc cp_rx_iy
      jsr get_iy
      jmp cp_x
    .endproc

    .proc cp_rx_m
      jsr get_m
      jmp cp_x
    .endproc 

  ; ADI

    .proc add_x
      clc
      adc R,x
      sta R,x
      tya
      adc R+1,x
      sta R+1,x
      rts
    .endproc
    ; adi ax, #2343
    .proc ad_rx_w
      jmp add_x
    .endproc

    ; adi ax, bx
    .proc ad_rx_ry
      jsr get_ry
      jmp add_x 
    .endproc

    ; adi ax, @bx
    .proc ad_rx_iy
      jsr get_iy
      jmp add_x
    .endproc

    ; adi ax, label
    .proc ad_rx_m
      jsr get_m
      jmp add_x
    .endproc 
  
  ; SBI
    .proc sub_x
      sec
      eor #$ff
      adc R,x
      sta R,x
      tya
      eor #$ff
      adc R+1,x
      sta R+1,x
      rts
    .endproc
    ; sbi ax, #2343
    .proc sb_rx_w
      jmp sub_x
    .endproc

    ; sbi ax, bx
    .proc sb_rx_ry
      jsr get_ry
      jmp sub_x 
    .endproc

    ; sbi ax, @bx
    .proc sb_rx_iy
      jsr get_iy
      jmp sub_x
    .endproc

    ; sbi ax, label
    .proc sb_rx_m
      jsr get_m
      jmp sub_x
    .endproc

  ; INI
    .proc in_ay
      clc
      adc #1
      bne skip
        iny
      skip:
      rts      
    .endproc

    .proc in_rx
      jsr get_rx
      jsr in_ay
      jmp set_rx
    .endproc

    .proc in_ix
      jsr get_ix
      jsr in_ay
      jmp set_m ; we aleady have the addess set by get_ix
    .endproc

    .proc in_m
      jsr get_m
      jsr in_ay
      jmp set_m ; we aleady have the addess set by get_m
    .endproc

  ; DEI
    
    .proc de_ay
      cmp #0
      beq skip
        dey
      skip:
      sec
      sbc #1
      rts      
    .endproc


    .proc de_rx
      jsr get_rx
      jsr de_ay
      jmp set_rx
    .endproc

    .proc de_ix
      jsr get_ix
      jsr de_ay
      jmp set_m ; we aleady have the addess set by get_ix
    .endproc

    .proc de_m
      jsr get_m
      jsr de_ay
      jmp set_m ; we aleady have the addess set by get_m
    .endproc

  ; PHI
    .proc in2_x
      clc
      lda R,x
      adc #2
      sta R,x
      bcc skip
        inc R-1,x
      skip:
      rts      
    .endproc

    .proc ph_rx_w
      jsr set_ix
      jmp in2_x
    .endproc


    .proc ph_rx_m
      jsr get_m
      jmp ph_rx_w
    .endproc

    .proc ph_rx_ry
      jsr get_ry
      jmp ph_rx_w
    .endproc

    .proc ph_rx_iy
      jsr get_iy
      jmp ph_rx_w
    .endproc

  ; PLI
    .proc de2_y
      pha
      sec
      lda R,y
      sbc #2
      sta R,y
      bcc skip
        lda R-1,y
        adc #1
        sta R-1,y
      skip:
      pla
      rts      
    .endproc

    .proc pl_y
      jsr de2_y
      jsr get_iy
      rts
    .endproc

    .proc pl_rx_ry
      jsr pl_y
      jmp set_rx
    .endproc

    .proc pl_ix_ry
      jsr pl_y
      jmp set_ix
    .endproc


.endscope

.macro mnemonic op, arg1, arg2
  .local left, right,fn
  .scope 
    .if .defined (VMI::IREGS::arg1)
      ldx #VMI::IREGS::arg1
      .define left "_ix"
    .elseif .defined (VMI::REGS::arg1)
      ldx #VMI::REGS::arg1
      .define left "_rx"
    .else
      lda #<arg1
      ldy #>arg1
      .define left "_m"
    .endif
    .ifblank arg2
      .define fn .ident(.concat(op,left))
    .else  
      .if (.match (.left (1, {arg2}), #))
        lda #<(.right (.tcount ({arg2})-1, {arg2}))
        ldy #>(.right (.tcount ({arg2})-1, {arg2}))
        .define right "_w" 
      .elseif (.match (.left (1, {arg2}), {=}))
        lda #<(.right (.tcount ({arg2})-1, {arg2}))
        ldy #>(.right (.tcount ({arg2})-1, {arg2}))
        .define right "_m" 
      .elseif .defined (VMI::IREGS::arg2)
        ldy #VMI::IREGS::arg2
        .define right "_iy"
      .elseif .defined (VMI::REGS::arg2)
        ldy #VMI::REGS::arg2
        .define right "_ry"
      .else
        lda #<arg2
        ldy #>arg2
        .define right "_m"
      .endif
      .define fn .ident(.concat(op,left,right))
    .endif
    .ifndef VMI::fn
      .error .concat("illegal addressing mode in VMI: ",.string(fn))
    .else
      jsr VMI::fn
    .endif
  .endscope
.endmacro

.macro ldi arg1, arg2
  .scope
    reg = VMI::R + VMI::REGS::arg1
    .if (.match (.left (1, {arg2}), #))
      ;.out .string(.right (.tcount ({arg2})-1, {arg2}))
      lda #.lobyte(.right (.tcount ({arg2})-1, {arg2}))
      sta reg
      lda #.hibyte(.right (.tcount ({arg2})-1, {arg2}))
      sta reg+1
    .else
      lda arg2
      sta reg
      lda arg2+1
      sta reg+1
    .endif
  .endscope
.endmacro

.macro sti arg1, arg2
  .scope
    reg = VMI::R + VMI::REGS::arg1
    lda reg
    sta arg2
    lda reg+1
    sta arg2+1
  .endScope
.endmacro

.macro mvi arg1, arg2
  mnemonic "mv", arg1, arg2
.endmacro

.macro adi arg1, arg2
  mnemonic "ad", arg1, arg2
.endmacro

.macro sbi arg1, arg2
  mnemonic "sb", arg1, arg2
.endmacro

.macro ini arg1, arg2
  mnemonic "in", arg1, arg2
.endmacro

.macro dei arg1, arg2
  mnemonic "de", arg1, arg2
.endmacro

.macro phi arg1, arg2
  mnemonic "ph", arg1, arg2
.endmacro

.macro pli arg1, arg2
  mnemonic "pl", arg1, arg2
.endmacro

.macro pri arg1, arg2
  .ifnblank arg2
    PrintString .concat(arg2,":")
  .endif
  mvi gg, arg1
  sti gg, print::arg
  jsr print::print_hex
  PrintChr ' '
.endmacro
