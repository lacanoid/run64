; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.

MAIN:
        LDY #MSG0-MSGBAS    ; display
        JSR SNDMSG

; copy
        leaxy $A000 ; copy basic
        stxy T1     ; set address
        ldx #32     ; number of pages to copy
        jsr copy

        leaxy $E000 ; copy kernal
        stxy T1     ; set address
        ldx #32     ; number of pages to copy
        jsr copy

        lda 1       ; switch kernel and basic roms out
        and #$FD
        sta 1

; patches

; kernal patches
; change default memory configuraton in R6510 to use RAM
        LDA #%11100101
        STA $fdd5+1   ; 
; patch ramtas to stop at $A000
        ldx #6
@l2:    lda ramtas2,X
        sta $fd79,X
        dex
        bpl @l2
; set default colors and device number
        lda #$16
        sta $ecb9+24  ; lowercase
        lda EXTCOL
        sta $ecd9     ; border color
        lda BGCOL0
        sta $ecda     ; backgorund color
        lda COLOR
        sta $e534+1   ; foreground color
        lda FA
        sta $e1d9+1   ; default device number for BASIC LOAD
; set last char of the startup message
        lda #'$'
        sta $e4a9

; basic patches
; change basic ready prompt to something else
        ldx #5      
@l1:    lda prompt,x
        sta $a378,x
        dex
        bpl @l1


; finnish up
        LDY #MSG1-MSGBAS    ; display message
        JSR SNDMSG

        rts

prompt:
        .byte "RUN64."

ramtas2:
        lda $c2
        cmp #$a0
        .byte $f0,$09  ; BEQ 9
        nop
;        .byte $a5,$c2,$c9,$a0,$f0,$09,$ea

; -----------------------------------------------------------------------------
; copy pages
copy:
        ldy #0
@loop1:
        LDA (T1),Y
        STA (T1),Y
        INY
        BNE @loop1
        dex
        beq @end1
        inc T2
        bne @loop1
@end1:
        RTS

; -----------------------------------------------------------------------------
; display message from table
SNDMSG: LDA MSGBAS,Y        ; Y contains offset in msg table
        PHP
        AND #$7F            ; strip high bit before output
        JSR CHROUT
        INY
        PLP
        BPL SNDMSG          ; loop until high bit is set
        RTS

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE 14
        .BYTE "PATCH64",' '+$80
MSG1:   .BYTE 14
        .BYTE "COPYING ROM TO RAM",' '+$80
