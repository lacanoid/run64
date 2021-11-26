; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs.inc"
.include "macros.inc"

.segment "STARTUP"

.segment "LOWCODE"

main:
        LDY #MSG_0-MSGBAS 
        JSR SNDMSG
        jsr load
        rts
;
load:
        LDA #$80            ; disable kernel control messages
        JSR SETMSG          ; and enable error messages

        lda #1
        ldx FA
        ldy #0
        jsr SETLFS

        lda #9
        leaxy fn1
        jsr SETNAM

        lda #0        ; load, not verify
        leaxy $A000
        JSR LOAD
        bcs error     ; no error

        lda #10
        leaxy fn2
        jsr SETNAM

        lda #0        ; load, not verify
        leaxy $E000
        JSR LOAD
        bcs error     ; no error

        ; patch
        LDY #MSG_2-MSGBAS 
        JSR SNDMSG

        ; bank 0
        sei
        lda #%00111110
        sta $ff00

        ; change default memory configuraton in R6510
        LDA #%11100011
        STA $FDD5+1   ; 

        ; copy last page of kernal
        ldy #5
@p1:
        lda data,y
        sta $ff00,y
        iny
        bne @p1

        jmp ($FFFC)   ; reboot

        rts

fn1:    .byte "BASIC.BIN"
fn2:    .byte "KERNAL.BIN"

error:
        LDY #MSG_1-MSGBAS 
        JSR SNDMSG
        rts

SNDMSG: 
        LDA MSGBAS,Y        ; Y contains offset in msg table
        PHP
        JSR CHROUT
        INY
        PLP
        BPL SNDMSG          ; loop until high bit is set
        RTS

MSGBAS  =*
MSG_0:.BYTE "HELLO",$20+$80
MSG_1:.BYTE "LOAD ERROR",$20+$80
MSG_2:.BYTE $0d,"PATCHING ",$20+$80

data:
        .byte $dd, $8d, $07, $dd, $4c, $59, $ef, $ad, $95, $02, $8d, $06, $dd, $ad, $96, $02
        .byte $8d, $07, $dd, $a9, $11, $8d, $0f, $dd, $a9, $12, $4d, $a1, $02, $8d, $a1, $02
        .byte $a9, $ff, $8d, $06, $dd, $8d, $07, $dd, $ae, $98, $02, $86, $a8, $60, $aa, $ad
        .byte $96, $02, $2a, $a8, $8a, $69, $c8, $8d, $99, $02, $98, $69, $00, $8d, $9a, $02
        .byte $60, $ea, $ea, $08, $68, $29, $ef, $48, $48, $8a, $48, $98, $48, $ba, $bd, $04
        .byte $01, $29, $10, $f0, $03, $6c, $16, $03, $6c, $14, $03, $20, $18, $e5, $ad, $12
        .byte $d0, $d0, $fb, $ad, $19, $d0, $29, $01, $8d, $a6, $02, $4c, $dd, $fd, $a9, $81
        .byte $8d, $0d, $dc, $ad, $0e, $dc, $29, $80, $09, $11, $8d, $0e, $dc, $4c, $8e, $ee
        .byte $03, $4c, $5b, $ff, $4c, $a3, $fd, $4c, $50, $fd, $4c, $15, $fd, $4c, $1a, $fd
        .byte $4c, $18, $fe, $4c, $b9, $ed, $4c, $c7, $ed, $4c, $25, $fe, $4c, $34, $fe, $4c
        .byte $87, $ea, $4c, $21, $fe, $4c, $aa, $fb, $4c, $dd, $ed, $4c, $ef, $ed, $4c, $fe
        .byte $ed, $4c, $0c, $ed, $4c, $09, $ed, $4c, $07, $fe, $4c, $00, $fe, $4c, $f9, $fd
        .byte $6c, $1a, $03, $6c, $1c, $03, $6c, $1e, $03, $6c, $20, $03, $6c, $22, $03, $6c
        .byte $24, $03, $6c, $26, $03, $4c, $9e, $f4, $4c, $dd, $f5, $4c, $e4, $f6, $4c, $dd
        .byte $f6, $6c, $28, $03, $6c, $2a, $03, $6c, $2c, $03, $4c, $9b, $f6, $4c, $05, $e5
        .byte $4c, $0a, $e5, $4c, $00, $e5, $52, $52, $42, $59, $43, $fe, $e2, $fc, $48, $ff

.segment "INIT"

