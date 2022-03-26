.include "defs128.inc"
.include "macros.inc"

.segment "STARTUP"
main:
        LDY #MSG_0-MSGBAS 
        JSR SNDMSG
        jsr init
        rts
;
.segment "LOWCODE"

.macro vdcout reg,val
    ldx #reg
    lda #val
    jsr VDCOUT
.endmacro

;-------------------------------------------

init: 
;       vdcout vdcreg_fgbg,$0c

        jsr irq_setup

;        jsr vdc_raster
        rts

blit:
    ; text
        lda #102
        ldx #0
        ldy VM3
        jsr fill
    ; attr
        lda #$0f
        ldx #0
        ldy VM4
        jsr fill
    rts

fill:
    w = 80
@ll2:
        pha
        jsr VDCADDR
        pla

        ldy #1
        sty COUNT

        ldy #w
        ldx #31

@ll1:   stx vdcadr
@vdco0:	bit vdcadr	;////// entry to write next sequential byte
	    bpl @vdco0
	    sta vdcdat

        clc
        adc #1

        dey
        bne @ll1

        dec COUNT
        bne @ll2
    rts

;-------------------------------------------
; irq

irq_setup:
        sei
        lda irq_stat
        bne @irqs2
@irqs1: 
        inc irq_stat
        ldx IIRQ        ; set new interrupt vector
        stx raster_cont+1
        ldy IIRQ+1
        sty raster_cont+2
@irqs2:
        ldx #<raster
        stx IIRQ
        ldy #>raster
        sty IIRQ+1 
        cli
        rts
irq_stat:
        .byte 0

raster:
        lda #2
        sta EXTCOL

        ; copy of c128 rom routine
        cld
        jsr $C024  ; editor irq routine
        bcc @ra1 
        jsr $F5F8  ; UDTIM
        jsr $EED0  ; tape motor ctl
        lda $dc0d  ; clear CIA irq
        lda $0a04  ; check if animations enabled
        lsr
        bcc @ra1
        jsr $4006  ; run basic animations
@ra1:
        lda #0
        sta EXTCOL
        jmp $ff33  ; CRTI return from interrupt


raster_cont:
        jmp $FA65

;-------------------------------------------

;-------------------------------------------
; vdc stuff


vdcadr	= $d600		;8563 address register
vdcdat	= $d601 	;8563 data    register

vdcreg_ua   = $12  ; VDC memory update address (A15-A8)
vdcreg_da   = $1f  ; Data register
vdcreg_fgbg = $1a  ; Foreground color (4), Background color (4)
vdcreg_hss  = $19  ; Bitmap, Attributes, Gap fill, Pixel clock, Horizontal smooth scroll (4)
vdcreg_ai   = $1b  ; Address increment per row

;-------------------------------------------
; vdc raster
vdc_raster:
        ; wait for vblank
        vdcout vdcreg_fgbg,$09
@vr1:
        lda vdcadr
        and #$20
        beq @vr1

        ; vblank reached

        vdcout vdcreg_fgbg,$08
        jsr blit
        vdcout vdcreg_fgbg,$f0

        ldx #15
        stx bgcol


@vr2:
        ; wait for display area
        lda vdcadr
        and #$20
        bne @vr2

        ; top if diplay area reached

        ; show some colors
@vr3:
        ldx #vdcreg_fgbg
        lda bgcol
        jsr VDCOUT
        sta EXTCOL

        jsr delay

        dec bgcol
        bpl @vr3

        jsr STOP
        bne vdc_raster
        rts

bgcol: .byte 0

;-------------------------------------------
; delay

delay:
    o1=128
        ldy #25
        ldx #31
@ll1:   lda VICSCN-1+o1,y
        tax
        inx
        txa
        sta VICSCN-1+o1,y
        dey
        bne @ll1
        rts

;-------------------------------------------
; vdc i/o

VDCPUT:	ldx #31		;update data register
VDCOUT:	stx vdcadr	;update 8563 register in .x with data in .a
@vdco1:	bit vdcadr	;////// entry to write next sequential byte
	    bpl @vdco1
	    sta vdcdat
	    rts

VDCGET:	ldx #31		;read data register
VDCIN:	stx vdcadr	;read 8563 register in .x, pass data in .a
@vdci1:	bit vdcadr	;////// entry to read next sequential byte
	    bpl @vdci1
	    lda vdcdat
	    rts

VDCADDR:	    
    ;setup 8563 update registers (18,19) with .Y (hi) and .X (lo)
    ; high byte
        lda #vdcreg_ua
        sta vdcadr
@vdad1:	bit vdcadr	;////// entry to read next sequential byte
	    bpl @vdad1
        sty vdcdat
    ; low byte
        lda #vdcreg_ua+1
        sta vdcadr
@vdad2:	bit vdcadr	;////// entry to read next sequential byte
	    bpl @vdad2
        stx vdcdat
        rts

;-------------------------------------------

SNDMSG: 
        LDA MSGBAS,Y        ; Y contains offset in msg table
        PHP
        JSR CHROUT
        INY
        PLP
        BPL SNDMSG          ; loop until high bit is set
        RTS

MSGBAS  =*
MSG_0:.BYTE "RASTER128",$d+$80

.segment "INIT"
