; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.
resultRegister = $d7ff

.code
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

.rodata
msg:    .asciiz "HELLO RASTER WORLD "

; --------------------------

.code
raster_setup:
        sei

        ldx CINV        ; set new interrupt vector
        stx raster_cont+1
        ldy CINV+1
        sty raster_cont+2
        ldx #<raster
        stx CINV
        ldy #>raster
        sty CINV+1 

        ldy #0          ; display list index
        sty T1
        lda IRQMASK     ; enable VIC raster interrupt
        ora #1
        sta IRQMASK
        lda #150        ; set initial raster line
        sta RASTER
        lda SCROLY
        and #$7f
        sta SCROLY

        rts

raster:
        asl VICIRQ
        bcc raster_not

        ; inc BGCOL0
;        lda BGCOL0
;        eor #7
;        sta BGCOL0
;        cli

        ldx #$6
@l1:    dex
        bne @l1
        nop
        nop
        nop

        ldy T1
raster_exec:   ; execute display list instructions
        lda raster_list,y   ; instruction value
;        sta $400
        tax
        iny
        lda raster_list,y   ; instruction type
;        sta $401

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
        sty T1
        bne raster_exec         ; always
        brk

raster_chk_wait:
        cmp #$02
        bcs raster_do_call      ; not a wait instruction

raster_do_wait:
;        jmp raster_rti

        cpx #0
        beq raster_list_restart ; end of list reached
        stx RASTER
        iny
        sty T1
 ;       jmp raster_rti
        bne raster_rti          ; always, return from IRQ
        brk

raster_do_call:
        ; not implemented yet
        iny
        sty T1
 ;       jmp raster_exec
        bne raster_exec         ; always
        brk

raster_list_restart:
        ldy #0
        sty T1
;        jmp raster_exec
        beq raster_exec         ; always

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

raster_list: 
        .word 1
        .word EXTCOL
        .byte 14
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
        .word 105        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 0
        .word 113        ; wait for line
        .word BGCOL0    ; set bgcolor to color 3
        .byte 8
        .word EXTCOL    ; set bgcolor to color 3
        .byte 8

        .word 0 ; end

