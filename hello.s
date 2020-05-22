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

done:   lda #0
        sta resultRegister
        rts

.rodata
msg:    .asciiz "HELLO WORLD!!!"