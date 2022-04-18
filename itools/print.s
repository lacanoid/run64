.ifndef ::__PRINT_INCLUDED__
::__PRINT_INCLUDED__ = 1

.include "defs/defs-auto.inc"
.include "macros/basics.inc"

.macro print fn
  .if (.match (.left (1, {fn}), {""}))
    prints fn
  .else
    jsr print::fn
  .endif
.endmacro

.macro prints arg
  .local string
  .pushseg 
  .data
    string:
    .byte arg, 0
  .popseg
  ldx #<string
  ldy #>string
  jsr print::z_at_xy
.endmacro

.scope print
  .data
    PP = _write_char+1
    CP = _write_color+1
    COLUMNS: .byte 40
    ROWS: .byte 25
    WIN_LEFT: .byte 0 
    WIN_TOP: .byte 0 
    WIN_WIDTH: .byte 40
    WIN_HEIGHT: .byte 25
    COLUMN: .byte 0
    COLUMNS_LEFT: .byte 0
    ROW: .byte 0
    ROWS_LEFT: .byte 0
    CHAR_OR: .byte 0
    arg: .word 0
  .code

  .proc rev_on
    pha
    lda #$80
    sta CHAR_OR
    pla
    rts
  .endproc
  
  .proc rev_off
    pha
    lda #$00
    sta CHAR_OR
    pla
    rts
  .endproc

  .proc set_tl
    stx WIN_LEFT
    sty WIN_TOP
    rts
  .endproc 

  .proc set_wh
    stx WIN_WIDTH
    sty WIN_HEIGHT
    rts
  .endproc 

  .proc reset_window
    CClear WIN_LEFT
    CClear WIN_TOP
    CMov WIN_WIDTH, COLUMNS
    CMov WIN_HEIGHT, ROWS
    jmp reset
  .endproc


  .proc reset
    jsr $FFED ; SCRORG
    stx COLUMNS
    sty ROWS
    pha
    lda #12
    jsr CHROUT
    ISet CP, COLORAM
    ISet PP, VICSCN
    ldx WIN_TOP
    beq skip
    set_row:
      lda COLUMNS
      IAddA CP
      lda COLUMNS
      IAddA PP
      dex
    bne set_row
    skip:
    CMov COLUMN,WIN_LEFT
    CMov COLUMNS_LEFT,WIN_WIDTH
    CMov ROW,WIN_TOP
    CMov ROWS_LEFT,WIN_HEIGHT
    pla
    rts
  .endproc

  .proc space
    lda #' '
    jmp _char
  .endproc

  .proc char
    sta rewrite+1
    and #$E0
    beq c80       ; $00 - $80 -> $80

    cmp #$40       
    beq c40      ; $40 - $40 -> $00

    cmp #$20       
    beq c00       ; $20 - $0 -> $20 

    cmp #$A0
    bcc cC0       ; $60 & $80 - $C0 -> $A0 & $C0
    beq c40       ; $A0 - $40  -> $60
    
    cmp #$C0
    bne c00       ; $E0 - $00 -> $E0
    ;pass through ; $C0 - $80 -> $40
    c80:
      lda #$80
      bne done
    cC0:
      lda #$40
      bne done
    c00:
      lda #$00
      bra done
    c40:
      lda #$C0
    done: 
    clc
    rewrite:
    adc #$ff 
  .endproc
  ; passthrough
  _char:
    ora CHAR_OR
    pha 
    ldx ROWS_LEFT
    bne not_eos
    jsr scroll_up
    not_eos:
    pla
    ldx COLUMN
  _write_char:
    sta $FEED,x
    lda COLOR
  _write_color:    
    sta $FEED,x
  ; passthrough
  _advance:
    dec COLUMNS_LEFT
    beq eol
    inc COLUMN
    clc 
    rts 
    eol:
      CMov COLUMN,WIN_LEFT
      CMov COLUMNS_LEFT,WIN_WIDTH
      inc ROW
      dec ROWS_LEFT
      beq eos
      lda COLUMNS
      IAddA PP
      lda COLUMNS
      IAddA CP
    eos:
      sec
      rts 

  .proc scroll_up
    .pushseg
    .data
      cur_row: .byte 0
      rows_left: .byte 0
    .popseg
    PushX
    PushY
    pha 
      ISet wrs+1, VICSCN 
      ISet wrc+1, COLORAM
      ISet rds+1, VICSCN
      lda COLUMNS
      IAddA rds+1
      ISet rdc+1, COLORAM
      lda COLUMNS
      IAddA rdc+1
      
      CSet cur_row,$FF
      CMov rows_left, WIN_HEIGHT
      dec rows_left
     
      row:
        inc cur_row
        lda cur_row
        cmp WIN_TOP
        bcc skip_row

        ldx WIN_WIDTH
        ldy WIN_LEFT
        col:
          rds: lda $FEED, y
          wrs: sta $FEED, y
          rdc: lda $FEED, y
          wrc: sta $FEED, y
          iny
          dex
        bne col
        dec rows_left
        beq done

        skip_row:
          lda COLUMNS 
          IAddA rds+1
          lda COLUMNS 
          IAddA wrs+1
          lda COLUMNS 
          IAddA rdc+1
          lda COLUMNS
          IAddA wrc+1
      bra row
      done: 
      dec ROW
      inc ROWS_LEFT
    pla
    PopY
    PopX
    rts
  .endproc 

  .proc nl
    spaces: 
      lda #' '
      jsr _char
    bcc spaces
    rts
  .endproc
  .proc spaces_to
    tay 
    spaces: 
      lda #' '
      jsr _char
      cpy COLUMN
    bne spaces
    rts
  .endproc
  .proc clear_rest
    nls: 
      lda ROWS_LEFT 
      beq exit 
      jsr nl
    bra nls
    exit:
    rts
  .endproc

  .proc number_a
    sta arg
    lda #0
    sta arg+1
    jmp number
  .endproc
  
  .proc number_xy
    stx arg
    sty arg+1
  .endproc
  ;passthrough
  .proc number
    ; print a 16 bit unsigned binary integer from stack in base 10
    ; leading zeros are omitted
    ; expects a pp to stack element in x

    print_uint16:
      lda      #0                  ; terminator for digits on stack
    print_uint16_1:
      pha                         ; push terminator or digit onto stack
      lda     #0                  ; accumulator for division
      clv                         ; v flag will be set if any quotient bit is 1
      ldy     #16                 ; number of input bits to process
    print_uint16_2:
      cmp     #5                  ; is accumulator >= 5 ?
      bcc     print_uint16_3
      sbc     #$85                ; if so, subtract 5, toggle bit 7 and set v flag (unwanted bit 7 will be shifted out imminently)
      sec                         ; set c (=next quotient bit)
    print_uint16_3:
      rol     arg              ; shift quotient bit into x while shifting out next dividend bit into a
      rol     arg+1
      rol                         ; shift dividend into a
      dey
      bne     print_uint16_2     ; loop until all original dividend bits processed
      ora     #$30                ; a contains remainder from division by 10 - convert to ascii digit
      bvs     print_uint16_1     ; if quotient was not zero, loop back to push digit on stack then divide by 10 again
  print_uint16_4:
      pha
      jsr char
      pla
      pla                         ; retrieve next digit from stack (or zero terminator)
      bne     print_uint16_4     ; if not terminator, print digit
      rts
  .endproc

  .proc z_at_xy
    stx read+1
    sty read+2
    ;jsr word_xy
    loop:
      read: lda $FADE
      beq exit
      IInc read+1
      jsr char
      bra loop
    exit:
      rts
  .endproc

  .proc z_at_xy_plus_a
    stx x2a +1
    sty y2a+1
    clc
    x2a: adc #00
    sta read+1
    y2a: lda #00
    adc #0
    sta read+2
    loop:
      read: lda $FADE
      beq exit
      IInc read+1
      jsr char
      bra loop
    exit:
      rts
  .endproc

  .proc byte_a
    pha
    lsr 
    lsr 
    lsr 
    lsr
    jsr nybble_a
    pla
  .endproc

  .proc nybble_a
    and #$0f
    cmp #10
    bcc skip
    adc #6
    skip:
    add #'0'
    jmp char
  .endproc

  .proc word_xy
    stx rw+1
    tya
    jsr byte_a
    rw: lda #$ff
    jmp byte_a
  .endproc
.endscope
.endif