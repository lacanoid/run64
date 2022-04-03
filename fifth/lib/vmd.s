
.scope VMI
  R: .res 32
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

  .proc read_rx
    lda R,x
    ldy R+1,x
    rts
  .endproc

  .proc write_rx
    sta R,x
    pha
    tya 
    sta R+1,x
    pla
    rts
  .endproc

  .proc read_ry
    stx tmp
    tya
    tax
    jsr read_rx
    ldx tmp
    rts
    tmp: .byte 0
  .endproc

  .proc write_ry
    sta R,y
    pha
    tya 
    sta R+1,y
    pla
    rts
  .endproc

  .proc read_ia
    jsr read_a
    ; continue
  .endproc

  .proc read_a
    sta lo+1
    sta hi+1
     
    sty lo+2
    sty hi+2
    stx tmp
    ldx #1
    hi:
    ldy $FADE,x
    lo:
    lda $FADE 
    ldx tmp
    rts
    tmp: .byte 0
  .endproc

  .proc read_ix
    jsr read_rx
    jmp read_a
  .endproc
  
  .proc read_iy
    jsr read_ry
    jmp read_a
  .endproc
  
  .proc write_ix
    pha  
    lda R,x 
    sta lo+1
    sta hi+1
    lda R+1,x 
    sta lo+2
    sta hi+2
    inc hi+1
    bne skip
    inc hi+2
    skip:
    pla
    lo:
    sta $FADE
    hi:
    sty $FADE
    rts
  .endproc 

  ; MVI
    ; mvi aa, bb
    .proc mv_rx_ry
      jsr read_ry
      jmp write_rx 
    .endproc

    ; mvi aa, xb
    .proc mv_rx_iy
      jsr read_iy
      jmp write_rx
    .endproc

    ; mvi xa, bb
    .proc mv_ix_ry
      jsr read_ry
      jmp write_ix
    .endproc

    ; mvi xa, xb
    .proc mv_ix_iy
      jsr read_iy
      jmp write_ix
    .endproc

  ; STI

    ; sti ax, label
    .proc st_x_a
      jmp write_ix
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
      jsr read_ry
      jmp add_x 
    .endproc

    ; adi ax, @bx
    .proc ad_rx_iy
      jsr read_iy
      jmp add_x
    .endproc

    ; adi ax, label
    .proc ad_rx_a
      jsr read_a
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
      jsr read_ry
      jmp sub_x 
    .endproc

    ; sbi ax, @bx
    .proc sb_rx_iy
      jsr read_iy
      jmp sub_x
    .endproc

    ; sbi ax, label
    .proc sb_rx_a
      jsr read_a
      jmp sub_x
    .endproc

  ; INI & DEI
    ; ini ax
    .proc in_rx
      inc R,x
      bne skip
      inc R+1,x
      skip:
      rts      
    .endproc

    ; ini @bx
    .proc in_ix
      txa
      pha
      jsr read_ix
      ldx #REGS::hh
      jsr write_rx
      jsr in_rx
      jsr read_rx 
      pla
      tax
      jmp write_ix
    .endproc

    ; dei ax
    .proc de_rx
      lda R,x
      bne skip
        dec R+1,x
      skip:
      dec R,x
      rts      
    .endproc

    ; ini @bx
    .proc de_ix
      stx tmp
      jsr read_ix
      ldx #REGS::hh
      jsr write_rx
      jsr de_rx
      jsr read_rx 
      ldx tmp
      jmp write_ix
      tmp:
        .byte 0
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
      .define left "_a"
    .endif
    .ifblank arg2
      .define fn .ident(.concat(op,left))
    .else  
      .if (.match (.left (1, {arg2}), #))
        lda #<(.right (.tcount ({arg2})-1, {arg2}))
        ldy #>(.right (.tcount ({arg2})-1, {arg2}))
        .define right "_w" 
      .elseif .defined (VMI::IREGS::arg2)
        ldy #VMI::IREGS::arg2
        .define right "_iy"
      .elseif .defined (VMI::REGS::arg2)
        ldy #VMI::REGS::arg2
        .define right "_ry"
      .else
        lda #<arg2
        ldy #>arg2
        .define right "_a"
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
      .out .string(.right (.tcount ({arg2})-1, {arg2}))
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

.macro pri arg1
  .local reg
  mvi gg, arg1
  sti gg, print::arg
  inc 646
  jsr print::print_hex
  inc 646

.endmacro
