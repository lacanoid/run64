; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.
resultRegister = $d7ff

        ldx #>(mainend-main)
        inx
        ldy #0
@l1:    lda data,Y
@l2:    sta $c000,y
        iny
        bne @l1
        inc @l1+2
        inc @l2+2
        dex 
        bpl @l1

        jmp $c000

data:
        .org $c000
main:
        ldx #0
print:  lda msg, x
        beq done
        jsr CHROUT
        inx
        bne print
done:

        jsr raster_setup
exit:
        lda #0
        sta resultRegister
        rts

msg:    .byte 14
        .asciiz "TOP BORDER MEMORY MONITOR"

; --------------------------

raster_setup:
        sei

        lda #$7f        ; disable CIA interrupts
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d

        ldx CINV        ; set new interrupt vector
        stx raster_cont+1
        ldy CINV+1
        sty raster_cont+2
        ldx #<raster
        stx CINV
        ldy #>raster
        sty CINV+1 

        ldy #0          ; display list index
        sty DLPOS
        lda IRQMASK     ; enable VIC raster interrupt
        ora #1
        sta IRQMASK
        lda #150        ; set initial raster line
        sta RASTER
        lda SCROLY
        and #$7f
        sta SCROLY

        ; setup some sprites
        lda BGCOL0
        sta raster_bgcol0
        lda #$FF
        sta SPRITEN
        lda #$80
        sta $d010
        lda #$01
        sta $3fff

        lda #64+24
        ldy #0
        ldx #0

@in1:   sta VIC2,x      ; x position
        inx
        clc
        adc #24
        pha

        lda #12
        sta VIC2,X      ; y position
        inx
        lda #1
        sta VIC2+39,Y   ; color
        tya
        sta 2040,y

        pla
        iny
        cpy #8
        bne @in1

        rts

        ; display list position
DLPOS:
        .byte 0

raster:                 ; new interrupt routine
        asl VICIRQ      ; ckh+clear VIC raster interrupt flag
        bcc raster_not  ; irq was not raster

        ; inc BGCOL0
;        lda BGCOL0
;        eor #7
;        sta BGCOL0
;        cli

        ldx #$7  ; time delay
@l1:    dex
        bne @l1
        nop

        ldy DLPOS

raster_exec:   ; execute display list instructions
        lda raster_list,y   ; instruction value
        tax
        iny
        lda raster_list,y   ; instruction type

raster_chk_poke:
        cmp #$d0            ; is it a poke?
        bcc raster_chk_wait ; not a poke instruction

raster_do_poke:
        sta raster_poke_sta+2 ; set up the address
        stx raster_poke_sta+1
        iny
        lda raster_list,y       ; register value
raster_poke_sta:
        sta $d020               ; store to register
        iny
;        sty DLPOS
        bne raster_exec         ; always
        brk

raster_chk_wait:
        cmp #$02
        bcs raster_do_call      ; not a wait instruction

raster_do_wait:
        stx RASTER
        cpx #0
        beq raster_list_restart ; end of list reached
        iny
        sty DLPOS
        bne raster_rti          ; always, return from IRQ
        brk

raster_do_call:
        iny
        sty DLPOS
        stx raster_dc1+1
        sta raster_dc1+2
raster_dc1:
        jsr raster_dummy
        ldy DLPOS
        bne raster_exec         ; always
        brk

raster_list_restart:
        ldy #0
        sty DLPOS
        beq raster_cont         ; always

raster_rti:
        pla
        tay
        pla
        tax
        pla
        rti

raster_not:
;        inc EXTCOL
;        lda EXTCOL
;        eor #7
;        sta EXTCOL

raster_cont:
        jmp $ea31

raster_dummy:
        pla
        pla
        jmp raster_cont

raster_border_begin:
        lda $d021
        sta raster_bgcol0
        lda $d020
        sta $d021
        rts

raster_border_end:
        lda raster_bgcol0
        sta $d021
        rts

raster_bgcol0:
        .byte 6

raster_sprbot:
        lda #255
        nop3
raster_sprtop:
        lda #22
        ldx #0
        ldy #1
@l1:    sta VIC2,Y
        iny
        iny
        inx
        cpx #8
        bne @l1
        rts

raster_spr1:
        ldx #8
        nop3
raster_spr0:
        ldx #0
        ldy #0
@l1:    txa
        sta 2040,y 
        inx
        iny
        cpy #8
        bne @l1
        rts

raster_list: 
;        .word 1         ; wait for line

        .word 5         ; wait for line
        .word SCROLY
        .byte 27
        .word raster_sprtop
        .word raster_spr0

        .word 49        ; wait for line
        .word raster_border_end
 
        .word 247       ; wait for line
        .word SCROLY
        .byte $13

        .word 249
        .word raster_border_begin
        .word raster_sprbot
        .word raster_spr1

        .word 0 ; end
mainend:
