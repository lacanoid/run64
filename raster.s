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

; print end program address
        lda TXTTAB+1
        jsr hexout
        lda TXTTAB
        jsr hexout
        lda #'-'
        jsr CHROUT
        lda VARTAB+1
        jsr hexout
        lda VARTAB
        jsr hexout
        lda #13
        jsr CHROUT

        jsr raster_setup
exit:
        lda #0
        sta resultRegister
        rts

; print hex A
hexout:
        pha
        lsr
        lsr
        lsr
        lsr
        jsr hexdig
        pla
        and #$0f
hexdig:
        cmp #$0a
        bcc hdsk1
        adc #$06
hdsk1:  adc #$30
        jsr CHROUT
        rts

.rodata
msg:    .asciiz "HELLO RASTER WORLD "

; --------------------------

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

        cli
        rts

raster:
        asl VICIRQ
        bcc raster_not

        inc BGCOL0


        ldy T1
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
        lda raster_list,y     ; register value
raster_poke_sta:
        sta $d020             ; store to register
        iny
        sty T1
        bne raster_exec       ; always
        brk

raster_chk_wait:
        cmp #$02
        bcs raster_do_call ; not a wait instruction
raster_do_wait:
        cmp #0
        beq raster_list_restart
        stx RASTER
        iny
        sty T1
        bne raster_rti
        brk

raster_do_call:
        ; not implemented
        iny
        sty T1
        bne raster_exec
        brk

raster_list_restart:
        ldy #0
        sty T1
        beq raster_exec       ; always

raster_rti:
        jmp raster_cont

raster_not:
        inc EXTCOL

raster_cont:
        jmp $ea31

raster_list: 
        .word 100 ; wait for line 100
        .word $d020 ; set border to color 2
        .byte 2
        .word 200 ; wait for line 200
        .word $d020 ; set border to color 3
        .byte 2
        .word 0 ; end

