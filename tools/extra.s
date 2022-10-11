listvars:
        ldxy  VARTAB
        stxy  T1

lvl2:   lda T2   ; at end?
        cmp ARYTAB+1
        bne lvl3
        lda T1
        cmp ARYTAB
lvl3:   bmi lvlgo
        rts

lvlgo:
        ldy #0
        lda (T1),y
        bmi lvnext1 ; it's a number
        iny
        lda (T1),y
        bpl lvnext1 ; not a string

        ldxy  T1
        jsr hexoutxy
        chrout ':'

        ldy #0
        lda (T1),y
        and #$7f
        jsr CHROUT
        iny
        lda (T1),y
        and #$7f
        bne @lvl4
        lda #' '
@lvl4: jsr CHROUT
        chrout ' '
        iny
        lda (T1),y
        sta COUNT
        jsr WRTWO
        chrout ' '
        iny 
        lda (T1),y
        tax
        iny
        lda (T1),y
        tay
        jsr hexoutxy
        chrout ' '
        lda COUNT
        jsr strout
        jsr CRLF
lvnext1:       
        ; next
        lda T1
        add #7
        sta T1
        bcc lvl2
        inc T2
        bne lvl2
;
