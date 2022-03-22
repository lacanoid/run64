
.proc interpret
    lda #0
    sta eof
    loop:
    jsr next_word
    lda eof
    beq loop
    rts
.endproc

.proc next_word

    ldx offset
    skip_space:
        lda input,x
        bne @ss1
    @ss2:
        inc eof
        rts
    @ss1:
        cmp #13
        beq @ss2
        cmp #33
        bcs skipped_space
        inx
        jmp skip_space
    skipped_space:
        stx offset


    lda input,x
    cmp #'$'
        bne not_hex
        jsr parse_hex 
        rts
    not_hex:
    cmp #'0'
        bcc not_dec
    cmp #'9'
        bcs not_dec
        jsr parse_dec
        rts
    not_dec:
        jsr parse_entry
        rts 
.endproc