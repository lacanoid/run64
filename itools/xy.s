; ldxy        - set XY to A
; ldxy #val   - set XY to val
; ldxy addr   - load XY from addr
; stxy addr   - store XY at addr
; xyld        - load A from (XY)
; xyldh       - load A from (XY+1)
; xyst        - load A from (XY)
; xysth       - load A from (XY+1)
; xyald       - load A from (XY+A)
; xyaldh      - load A from (XY+A+1)
; inxy        - incrase XY
; dexy        - decrease XY
; adxy        - add A to XY
; adxy #val   - add val to XY
; adxy addr   - add byte at addr to XY
; sbxy        - subtract A from XY
; sbxy #val   - subtract val from XY
; sbxy addr   - subtract byte at addr from XY
; ldixy       - load XY from (XY)
; ldixy addr  - load XY from (addr)
; stixy addr  - store XY at (addr)
; phxy        - push XY to stack
; plxy        - pull XY to stack
; xypl        - pull value from stack and store at (XY)
; xyrd        - xyld + inxy
; xywr        - xyst + inxy


.ifndef ::__XY_INCLUDED__
::__XY_INCLUDED__ = 1
.include "macros/basics.inc"
.macro ldxy arg
  .ifblank arg
    ldy #0
    tax
  .elseif (.match (.left (1, {arg}), #))
    ldx #<(.right (.tcount ({arg})-1, {arg}))
    ldy #>(.right (.tcount ({arg})-1, {arg}))
  .else
    ldx arg
    ldy arg+1
  .endif
.endmacro

.macro stxy arg
  stx arg
  sty arg+1
.endmacro

.macro ldixy arg
  .ifnblank arg 
    ldxy arg
  .endif
  goxy
.endmacro

.macro rdxy arg
  .ifnblank arg 
    ldxy arg
  .endif
  goxy
.endmacro

.macro stixy arg
  phxy
  ldxy arg
  jsr xy::finish_stixy
.endmacro

.macro wrixy arg
  phxy
  ldxy arg
  jsr xy::finish_wrixy
.endmacro


.macro xyld
  .local rw
  sty rw+2
  rw: lda $FA00,x
.endmacro

.macro xyldh
  .local rw
  sty rw+2
  rw: lda $FA01,x
.endmacro

.macro xyst
  .local rw
  sty rw+2
  rw: sta $FA00,x
.endmacro

.macro xysth
  .local rw
  sty rw+2
  rw: sta $FA01,x
.endmacro

.macro xyin
  .local rw
  sty rw0+2
  rw0: inc $FA00,x
.endmacro

.macro xyde
  .local rw
  sty rw0+2
  rw0: dec $FA00,x
.endmacro



.macro xyald
  jsr xy::indexed
.endmacro
.macro phxy
  jsr xy::phxy
.endmacro
.macro plxy
  jsr xy::plxy
.endmacro

.macro xypl
  jsr xy::xypl
.endmacro

.macro inxy
  .local skip
  inx
  bne skip
  iny
  skip:
.endmacro
  
.macro dexy 
  cpx #0
  bne skip
    dey
  skip:
  dex
.endmacro

.macro xyrd 
  jsr xy::read
.endmacro

.macro xywr 
  jsr xy::write
.endmacro

.macro adxy arg
  .ifnblank arg
    pha
    lda arg
    jsr xy::add
    pla
  .else 
    jsr xy::add
  .endif
.endmacro

.macro adsxy arg
  .ifnblank arg
    pha
    lda arg
    jsr xy::adds
    pla
  .else 
    jsr xy::adds
  .endif
.endmacro

.macro sbxy arg
  .ifnblank arg
    pha
    lda arg
    jsr xy::sub
    pla
  .else 
    jsr xy::sub
  .endif
.endmacro

.macro goxy
  jsr xy::deref
.endmacro

.macro jsxy 
  jsr xy::jsxy
.endmacro

.macro jsixy 
  jsr xy::jsixy
.endmacro

.macro jpxy 
  jmp xy::jsxy
.endmacro

.macro jpixy 
  jmp xy::jsixy
.endmacro

.scope xy
  .pushseg
  .data 
    .align 2
    STACK: .res 16
    STACK_END:
    SP: .byte STACK_END-STACK
    S0: .byte 0
    S1: .byte 0
    P0: .byte 0
    P1: .byte 0
  .popseg 

  .proc drop
    stx rwx+1
    ldx SP
    inx
    lda STACK,x
    sta S0
    inx
    lda STACK,x
    sta S1
    stx SP
    rwx: ldx #0
    rts
  .endproc

  .proc push
    stx rwx+1
    ldx SP
    dex 
    lda S1
    sta STACK,x

    dex 
    lda S0 
    sta STACK,x
    stx SP
    rwx: ldx #$AA
    rts
  .endproc

  
  .proc phxy
    jsr push
    stxy S0
    rts
  .endproc

  .proc plxy
    ldxy S0
    jmp drop
  .endproc

  .proc xypl
    pha
    lda S0
    xyst 
    lda S1
    xysth
    pla
    jmp drop
  .endproc

  .proc jsxy
    stxy rw+1
    rw: jmp $FADE
  .endproc

  .proc jsixy
    stxy rw+1
    rw: jmp ($FADE)
  .endproc

  .proc deref
    pha
    sty lo+2
    sty hi+2
    hi: ldy $AA01,x
    lo: lda $AA00,x
    tax
    pla
    rts  
  .endproc

  .proc read
    xyld
    inxy
    rts
  .endproc 

  .proc write
    xyst
    inxy
    rts
  .endproc 

  .proc pop
    dexy
    xyld
    rts
  .endproc 

  .proc indexed
    PushX
    PushY
      adxy
      xyld
    PopY
    PopX
    rts
  .endproc 

  .proc finish_stixy 
    lda S0
    xyst 
    lda S0+1
    xysth
    plxy
    rts 
  .endproc
 
  .proc adds 
    pha
    stx rwx+1
    sty rwy+1
    clc
    rwx: adc #00
    tax 
    pla
    pha
    bmi minus
    lda #00
    .byte $2c
    minus: lda #$ff
    rwy: adc #00
    tay
    pla
    rts
  .endproc

  .proc add
    pha
    stx rw+1
    clc
    rw: adc #00
    tax 
    bcc skip 
      iny
    skip:
    pla
    rts
  .endproc

  .proc sub
    pha
    sta rw+1
    txa 
    sec
    rw: sbc #00
    tax
    bcs skip 
      dey
    skip:
    pla
    rts
  .endproc

  .proc findz
    PushX
    stx rw+1 
    sty rw+2
    ldx #0
    loop:
      rw: lda $FEED,x
      bne not_found
        clc
        txa
        bcc exit
      not_found:
      inx
    bne loop
    sec
    exit:
    PopX
    rts
  .endproc 

  .proc lookup
    pha
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
      pla; pha from before
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
    pla
    clc
    rts 
    read:
    rw: lda $FEED,y
    rts
  .endproc
.endscope 
.endif