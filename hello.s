; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.
resultRegister = $d7ff

kmon:
        msg hello
        
main:   jsr nl
        lda FA
        jsr hexout
        msg prompt
        ldx #0
more:   jsr CHRIN
        sta BUF,X
        inx
        cmp #13
        bne more
        stx COUNT
        dec COUNT
        beq main

        jsr nl

;        txa 
;        jsr hexout

        jsr execute

;        jsr dicfind
;        jsr hexoutxynl

        jmp main
        rts

hello:  .byte 14
        .asciiz "KMON 0.1"

len:
        .byte 0

prompt:
        .asciiz "$"

exit:
        lda #0
        sta resultRegister
        rts

execute:
        lda BUF
        cmp #'M'
        bne e1
        jmp meminfo
e1:     cmp #'B'
        bne e2
        jmp basicinfo
e2:     cmp #'V'
        bne e3
        jmp vectorinfo
e3:     cmp #'X'
        bne e4
        pla
        pla 
        rts
e4:     cmp #'.'
        bne e5
        jsr $c000
        rts
e5:     cmp #'O'
        bne ee
        jmp old
ee:     msg err_command
        rts

err_command:
        .asciiz "?"

old:    lda #1
        tay
        sta (TXTTAB),y
        jsr LINKPRG
old2:   
        ldx EAL
        stx VARTAB
        ldy EAL+1
        sty VARTAB+1
        rts

; in: xy = dict, BUF = string, COUNT = string length
; out: xy = address 
dictfind:
        stxy T1
        ldy #0
        lda COUNT
        sta VERCK

dctfl2:
        ; compare length
        lda (T1),y
        beq dctfx ; end of list, not found
        sta COUNT
        cmp VERCK
        bne next ; no match
        iny

        ; compare strings

dctfl:
        lda BUF-1,y
        cmp (T1),y
        bne next1 ; no match
        iny
        cpy VERCK
        bne dctfl
found:


next1: ; not found
       

next:  ; next item
        tya
        add COUNT
        tay

        clc
        bcc dctfl2

dctfx:
        rts

builtin:
        .byte 1,"X"
        .word 1
        .byte 2,"SH"
        .word info
        .byte 3,"SET"
        .word 2
        .byte 3,"DIR"
        .word 3
        .byte 3,"RUN"
        .word 4
        .byte 3,"NEW"
        .word 5
        .byte 4,"LIST"
        .word 6
        .byte 4,"HELP"
        .word 7
        .word 0

info:
meminfo:
        msg msg0
        sec
        jsr MEMBOT
        jsr hexoutxynl

textinfo:
        msg msg1
        ldxy TXTTAB
        jsr hexoutxynl
        msg msg2
        ldxy VARTAB
        jsr hexoutxynl
        msg msg3
        ldxy ARYTAB
        jsr hexoutxynl
        msg msg4
        ldxy STREND
        jsr hexoutxynl
        msg msg5
        ldxy FRETOP
        jsr hexoutxynl
        msg msg6
        ldxy MEMSIZ
        jsr hexoutxynl
        msg msgN
        sec
        jsr MEMTOP
        jsr hexoutxynl

        msg msgE
        ldxy EAL
        jsr hexoutxynl

        rts




basicinfo:
        msg msgb1
        ldxy IERROR
        jsr hexoutxynl
        msg msgb2
        ldxy IMAIN
        jsr hexoutxynl
        msg msgb3
        ldxy ICRNCH
        jsr hexoutxynl
        msg msgb4
        ldxy IQPLOP
        jsr hexoutxynl
        msg msgb5
        ldxy IGONE
        jsr hexoutxynl
        msg msgb6
        ldxy IEVAL
        jsr hexoutxynl

        rts

vectorinfo:
        msg msgc1
        ldxy CINV
        jsr hexoutxynl
        msg msgc2
        ldxy CBINV
        jsr hexoutxynl
        msg msgc3
        ldxy NMINV
        jsr hexoutxynl

        rts

msgc1:  .asciiz "CINV    "
msgc2:  .asciiz "CBINV   "
msgc3:  .asciiz "MNINV   "



msgout:  stx T1
         sty T2
         ldy #0
moprint: lda (T1),y
         beq modone
         jsr CHROUT
         iny
         bpl moprint
modone:
         rts


hexoutxynl:
        jsr hexoutxy
nl:     lda #13
        jsr CHROUT
        rts

; print hex A
hexoutxy:
        tya 
        jsr hexout
        txa 
        jsr hexout
        rts
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
msg0:   .asciiz "MEMBOT  "
msg1:   .asciiz "TXTTAB  "
msg2:   .asciiz "VARTAB  "
msg3:   .asciiz "ARYTAB  "
msg4:   .asciiz "STREND  "
msg5:   .asciiz "FRETOP  "
msg6:   .asciiz "MEMSIZ  "
msgN:   .asciiz "MEMTOP  "
msgE:   .asciiz "EAL     "

msgb1:  .asciiz "IERROR  "
msgb2:  .asciiz "IMAIN   "
msgb3:  .asciiz "ICRNCH  "
msgb4:  .asciiz "IQPLOP  "
msgb5:  .asciiz "IGONE   "
msgb6:  .asciiz "IEVAL   "
