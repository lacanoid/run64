; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.
resultRegister = $d7ff

CHROUT = $ffd2

.code
        ldx #0
print:  lda msg, x
        beq done
        jsr CHROUT
        inx
        bne print
done:

; print end of program address
        lda 44
        jsr hexout
        lda 43
        jsr hexout
        lda #'-'
        jsr CHROUT
        lda 46
        jsr hexout
        lda 45
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
        bcc hdskip1
        adc #$06
hdskip1:adc #$30
        jsr CHROUT
        rts

.rodata
msg:    .asciiz "HELLO WORLD "