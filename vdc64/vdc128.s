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
;        jsr blit2

        rts

        jsr vdc_raster

@i1:    jsr STOP
        beq @i1

        jsr blit2
        rts

blit:
    ; text
        lda cc
        ldx #0
        ldy VM3
        jsr fill
    ; attr
        lda cc
        ldx #0
        ldy VM4
        jsr fill

        inc cc
    rts

cc:     .byte 0

fill:
    w = 160
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
@ll3:	sta vdcdat

        clc
        adc #1

        dey
        bne @ll3

        dec COUNT
        bne @ll2
    rts

;-------------------------------------------
blit2:
        jsr sidsetup
        lda #$80
        sta T1
@bl2:
        ldx #0
        ldy VM3
        jsr VDCADDR
        jsr fill2
        jsr STOP
        bne @bl2

@i1:    jsr STOP
        beq @i1

        lda #$00
        sta T1
@bl3:
        ldx #0
        ldy VM4
        jsr VDCADDR
        jsr fill2
        jsr STOP
        bne @bl3

        rts
fill2:

        ldy #25
        sty COUNT

@lll2:
        ldy #80

@lll1:
        ldx #vdcreg_da

        stx vdcadr
@vdco0:	bit vdcadr	;////// entry to write next sequential byte
	bpl @vdco0
@lll3:	sta vdcdat

        lda $d41b       ; random
        ;and #$f
;        bit T1
;        bpl @l2
;        and #$3
;        tax
;        lda graf,x
@l2:
        dey
        bne @lll3

        dec COUNT
        bne @lll2
    rts

graf0:
        .byte $53,$41,$58,$5a
        .byte $51,$57,$20,$20
graf:
        .byte $20,$62,$e2,$a0
graf1:
        .byte $40,$5d,$20,$20
        .byte $49,$4a,$4b,$55
        .byte $6d,$6e,$70,$7d
        .byte $71,$72,$73,$6b

;-------------------------------------------
; irq

irq_setup:
        sei
        lda irq_stat
        bne @irqs2
@irqs1: 
        inc irq_stat
        ldx IIRQ        ; set new interrupt vector
        stx irq_cont+1
        ldy IIRQ+1
        sty irq_cont+2
@irqs2:
        ldx #<new_irq
        stx IIRQ
        ldy #>new_irq
        sty IIRQ+1 
        cli

cia_init:
        ; enable cia interrupts
        lda #$81
        sta cia1+$d     ; enable interrupts

        t0 = 18950   ; timer value 17045

        ldx #<t0
        ldy #>t0
cia_setup:
        stx cia1+4
        sty cia1+5

        lda #$09        ; one shot timer a
        sta cia1+$e     ; start timer a

        rts
irq_stat:
        .byte 0         ; already hooked

new_irq:
        cld
	lda vicreg+25	;is this a vic raster irq?
	and #$01
        bne raster

        ; not raster irq, must be 
        ; CIA interrupt

        lda cia1+$0d    ; clear cia
        inc EXTCOL
        jsr dlstep      ; load vdc registers from display list
;        jsr delay
        dec EXTCOL
;        vdcout vdcreg_fgbg,$0f
        jmp CRTI

raster:
        lda #2
        sta EXTCOL

        ; copy of c128 rom routine
        cld
        jsr $C024       ; editor irq routine
        bcc @ra1 
        jsr UDTIM       ; UDTIM
        jsr $EED0       ; tape motor ctl
;        lda cia1+$0d    ; clear CIA irq
        lda $0a04       ; check if animations enabled
        lsr
        bcc @ra1
        jsr $4006  ; run basic animations
@ra1:
        lda #0
        sta EXTCOL
        jmp CRTI  ; CRTI return from interrupt


irq_cont:
        jmp $FA65

;-------------------------------------------
; set up SID random generator

sidsetup:
        LDA #$FF  ; maximum frequency value
        STA $D40E ; voice 3 frequency low byte
        STA $D40F ; voice 3 frequency high byte
        LDA #$80  ; noise waveform, gate bit off
        STA $D412 ; voice 3 control register
        RTS

;-------------------------------------------
; vdc stuff

vicreg  = $d000         ;vic registers
cia1    = $dc00
cia2    = $dd00

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
        
        vdcout vdcreg_fgbg,$09
@vr1:   ; wait for vblank
        lda vdcadr
        and #$20
        beq @vr1

        ; vblank reached

        vdcout vdcreg_fgbg,$08
        jsr blit
;        jsr delay
        vdcout vdcreg_fgbg,$f0

        ldx #8
        stx bgcol
        jsr dleol

@vr2:   ; wait for display area        
        lda vdcadr
        and #$20
        bne @vr2

        ; top if diplay area reached

        ; show some colors
.if 1
@vr3:
        jsr dlstep
        jsr delay
        vdcout vdcreg_fgbg,$0f
        dec bgcol
        bpl @vr3
.else
@vr3:
        ldx #vdcreg_fgbg
        lda bgcol
        jsr VDCOUT
        sta EXTCOL

        jsr delay

        dec bgcol
        bpl @vr3
.endif




        jsr STOP
        bne vdc_raster

        rts

bgcol: .byte 0

;-------------------------------------------
; vdc display list

dlstep:
        ldy dlptr
        bne  dlstep1

        ; beginning of the list
@vr1:   ; wait for vblank
        lda vdcadr
        and #$20
        beq @vr1

dlstep1:
        ; setup timer
        lda display_list,Y
        sta cia1+4
        iny  
        lda display_list,Y
        sta cia1+5
        lda #$09        ; one shot timer a
        sta cia1+$e     ; start timer a
        iny

@dl2:   lda display_list,y    ; vdc register
        beq dladv            ; end of item advance
        bmi dleol            ; end of list
        sta vdcadr
        INY
        lda display_list,Y

@dl1:   bit vdcadr
        bpl @dl1
        sta vdcdat

        iny
        bne @dl2
        ; overflow, list too long?
        ; BRK

dleol:
        ldy #$ff
dladv: ; advance to next raster line
        iny
        sty dlptr
        rts

dlptr:  .byte 0  ; index

        clk0 = 63*8
display_list:
        .word clk0*9
        .byte vdcreg_fgbg,$0f,0
        .word clk0
        .byte vdcreg_fgbg,$0e,0
        .word clk0
        .byte vdcreg_fgbg,$0d,0
        .word clk0
        .byte vdcreg_fgbg,$0c,0
        .word clk0
        .byte vdcreg_fgbg,$0b,0
        .word clk0
        .byte vdcreg_fgbg,$0a,0
        .word clk0
        .byte vdcreg_fgbg,$09,0
        .word clk0
        .byte vdcreg_fgbg,$08,0
        .word clk0
        .byte vdcreg_fgbg,$07,0
        .word clk0
        .byte vdcreg_fgbg,$06,0
        .word clk0
        .byte vdcreg_fgbg,$05,0
        .word clk0
        .byte vdcreg_fgbg,$04,0
        .word clk0
        .byte vdcreg_fgbg,$03,0
        .word clk0
        .byte vdcreg_fgbg,$02,0
        .word clk0
        .byte vdcreg_fgbg,$01,0
        .word clk0
        .byte vdcreg_fgbg,$00,$ff

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
