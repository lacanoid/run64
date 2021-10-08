; C128 boot sector that copies C64 autostart code to $8000, and then switches 
; to C64 mode.

.include "config.inc"
.include "defs128.inc"

.import __CARTHDR_LOAD__, __CARTHDR_RUN__, __CARTHDR_SIZE__
.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __RUN64_RUN__
.import __TBUFFR_RUN__
.import devnum_sav

C64DEST = $801   ; relocation destination address (c64 basic)
DE      = $C3

RUN64   = __RUN64_RUN__

.segment "VICGO64"
go64old:
        jmp RUN64

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

; copy C64 autostart code into place
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
        
        JMP C64MODE ; c64 mode will take it from here

