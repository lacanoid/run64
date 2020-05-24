; C128 boot sector that copies C64 autostart code to $8000, and then switches 
; to C64 mode.

.include "config.inc"
.include "defs.inc"

.import __CARTHDR_LOAD__, __CARTHDR_RUN__, __CARTHDR_SIZE__
.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __RUN64_RUN__
.import __TBUFFR_RUN__
.import devnum_sav

KBDBUF = $034A  ; start of keyboard buffer for C64 screen editor
KBDCNT = $D0    ; keyboard buffer count for C64 screen editor
DEVNUM = $BA
SAL    = $AC
DEST   = $801
DE     = $C3

RUN64  = __RUN64_RUN__

.segment "GO64"
go64old:
        jmp RUN64

.if !LOADMODE
; reloacte (copy) basic program loaded in c128 mode at $1c00/$8000 to $0801 for c64
relocate:
;        brk
        sei
        lda #< DEST
        sta DE
        lda #> DEST
        sta DE+1
        sta $ff01  ; select bank 0

        LDX  #220  ; number of pages
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

        ; brk

        stx $ff00
        JMP C64MODE ; c64 mode will take it from here

