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
        lda #1
        sta COLOR
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

msg:    .asciiz "RASTER DISPLAY LIST DEMO"

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
        lda #$FF
        sta SPRITEN
        lda #20
        ldy #0
        ldx #0

@in1:   sta VIC2,x      ; x position
        inx
        clc
        adc #24
        pha

        lda #20
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

raster_buzz:
        nop
        ldx #9
@rb0:   dex
        bne @rb0

        ldy #$f
@rb2:   lda cmap,y
        sta EXTCOL
        ldx #8
@rb1:   dex
        bne @rb1
        nop
        nop
        nop
        bit 0
        dey 
        bpl @rb2
        rts

cmap:
        .byte 0,1,0,1,0,1,0,2
        .byte 0,1,0,1,0,1,0,3
        .byte 0,1,0,1,0,1,0,4
        .byte 0,1,0,1,0,1,0,5

colors_flip:
        lda cflag1
        bne cflip
cflop:
        inc cflag1
        leaxy cols2
        stxy cfl1+1
        jmp cf_do
cflip:
        dec cflag1
        leaxy cols1
        stxy cfl1+1

cf_do:
        ldx #0
        ldy #0
cfl1:   lda cols1,y
        sta colsdl,x
        txa
        clc
        adc #5
        tax
        iny
        cpy #8
        bne cfl1

        lda cflag1


        rts
cflag1:
        .byte 0
cols1:
        .byte  1, 7, 3, 5, 4, 2, 6, 0
cols2:
        .byte 13,15,10,12,14, 8,11, 9

raster_list: 
        .word 1         ; wait for line
        .word EXTCOL
        .byte 14
        .word BGCOL0
        .byte 14
        .word 5         ; wait for line
        .word SCROLY
        .byte 27

        .word 32
        .word EXTCOL
        .byte 15

        .word 48        ; wait for line 
        .word BGCOL0    ; set bgcolor to color 2
        .byte 1
        .word 57        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 7
        .word 65        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 3
        .word 73        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 5
        .word 81        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 4
        .word 89        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 2
        .word 97        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 6
        .word 105       ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 0

        .word 113        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 13
        .word 121        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 15
        .word 129        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 10
        .word 137        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 12
        .word 145        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 14
        .word 153        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 8
        .word 161        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 11
        .word 169        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 9

 
        .word 177        ; wait for line 
 
;         .word BGCOL0    ; set bgcolor to color 2
colsdl:
;         .byte 1
;         .word 185       ; wait for line
;         .word BGCOL0    ; set bgcolor to color 3
;         .byte 7
;         .word 193       ; wait for line
;         .word BGCOL0    ; set bgcolor to color 3
;         .byte 3
;         .word 201       ; wait for line
;         .word BGCOL0    ; set bgcolor to color 3
;         .byte 5
;         .word 209       ; wait for line
;         .word BGCOL0    ; set bgcolor to color 3
;         .byte 4
;         .word 217       ; wait for line
;         .word BGCOL0    ; set bgcolor to color 3
;         .byte 2
;         .word 225       ; wait for line
;         .word BGCOL0    ; set bgcolor to color 3
;         .byte 6
;         .word 233       ; wait for line
;         .word BGCOL0    ; set bgcolor to color 3
;         .byte 0
;         .word 241        ; wait for line


        .word BGCOL0    ; set bgcolor to color 3
        .byte 11
        .word EXTCOL    ; set bgcolor to color 3
        .byte 13
        .word 247       ; wait for line
        .word SCROLY
        .byte $13
        .word 255       ; wait for line
        .word raster_buzz
;        .word colors_flip

        .word 0 ; end
mainend:
