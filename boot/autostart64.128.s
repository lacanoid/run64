; C128 boot sector that copies C64 autostart code to $8000, and then switches 
; to C64 mode.

.include "config.inc"
.include "defs128.inc"
.include "macros.inc"
.include "boot.inc"

.import __CARTHDR_LOAD__, __CARTHDR_RUN__, __CARTHDR_SIZE__
.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __VICGO64_SIZE__, __VICGO64_LOAD__, __VICGO64_RUN__
.import __RUN64_RUN__
.import __TBUFFR_RUN__
.import devnum_sav

bootctl = $B11   ; boot parameters
C64DEST = $801   ; relocation destination address (c64 basic)
DE      = $C3

RUN64   = __RUN64_RUN__

.segment "GO64"
go64old:
;        jsr PRIMM
;        .byte 14,145,"GO 64  ",0

; Screen memory at $400 survives transition to c64 mode. 
; Below $400 is wiped on reset. Above $800 (up to $D000) is the loaded program.

; copy go64 routine to boot block screen memory, so that boot block buffer can be freed
        LDX  #< (__VICGO64_SIZE__ + __CARTHDR_SIZE__ + __AUTOSTART64_SIZE__ + 1)
@loop4: LDA __VICGO64_LOAD__ - 1, X
        STA VICGO64 - 1, X
        DEX
        BNE @loop4

; adjust EAL (end-of load pointer) for 64 mode
        sec
        lda EAL
        sbc SAL
        sta EAL
        lda EAL+1
        sbc SAL+1
        sta EAL+1
        clc
;        lda EAL
;        adc #< C64DEST
;        sta EAL
        inc EAL
        lda EAL+1
        adc #> C64DEST
        sta EAL+1
;        tax

        jmp VICGO64  ; VICGO64 + 3

.segment "VICGO64"
go64:
.if !LOADMODE
; reloacte (copy) basic program loaded in c128 mode at $1c00/$8000 to $0801 for c64
relocate:
        lda #< C64DEST
        sta DE
        lda #> C64DEST
        sta DE+1
        sta $ff01  ; select bank 0

        ; LDX  #220  ; number of pages
        ldx EAL+1 
        inx

        sei
        LDY  #0
@loop3: lda  (SAL),Y
        sta  (DE),Y
        INY
        bne @loop3
        inc SAL+1
        inc DE+1
        dex
        bne @loop3
.endif

; copy C64 autostart code into place from screen to $8000, 
; swap bytes with original at $8000
; they will be restored when in c64 mode
copy:   LDX  #< (__CARTHDR_SIZE__ + 1)
@loop:  
        LDA VICCRTB - 1, X
        TAY
        LDA __CARTHDR_RUN__ - 1, X
        STA VICCRTB - 1, X
        TYA
        STA __CARTHDR_RUN__ - 1, X
        DEX
        BNE @loop

        stx $ff00
        
        JMP C64_MODE ; c64 mode will take it from here

