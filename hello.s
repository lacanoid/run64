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
msg:    .asciiz "HELLO WORLD AT "

