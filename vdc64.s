; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.
resultRegister = $d7ff

        ldx #>(mainend-main)
        inx
        ldy #0
@l1:    lda data,Y
@l2:    sta $c000,y
        iny
        bne @l1
        inc @l1+2
        inc @l2+2
        dex 
        bpl @l1

        jmp $c000

; --------------------------
data:
        .org $c000
main:
        ldx #0
print:  lda msg, x
        beq done
        jsr CHROUT
        inx
        bne print
done:
;        jsr raster_setup
exit:
        lda #0
        sta resultRegister
        rts

msg:    .asciiz "RASTER DISPLAY LIST DEMO"

; --------------------------

sedsal  = $FB

vicchr	= $d000	        ;vic character rom
vicreg  = $d000         ;vic registers
viccol	= $d800		;vic color nybbles

sidreg	= $d400		;sid registers

vdcadr	= $d600		;8563 address register
vdcdat	= $d601 	;8563 data    register

vdcscn	= $0000		;8563 80-column screen	(2KB)
vdccol	= $0800		;8563 attribute area	(2KB)
vdcchr	= $2000		;8563 character ram	(4KB: 256 chrs, 8x16)

; further definitions
blnsw   = $cc

;////////////////   E D I T O R     J U M P     T A B L E   \\\\\\\\\\\\\\\\\
	jmp cint	;initialize editor & screen
	jmp disply	;display character in .a, color in .x
;	jmp lp2		;get a key from irq buffer into .a
;	jmp loop5	;get a chr from screen line into .a
	jmp print	;print character in .a
;	jmp scrorg	;get size of current window (rows,cols) in .x, .y
;	jmp scnkey	;scan keyboard subroutine
;	jmp repeat	;repeat key logic & 'ckit2' to store decoded key
	jmp plot	;read or set (.c) cursor position in .x, .y
;	jmp cursor	;move 8563 cursor subroutine
;	jmp escape	;execute escape function using chr in .a
;	jmp keyset	;redefine a programmable function key
;	jmp irq		;irq entry
;	jmp init80	;initialize 80-column character set
;	jmp swapper	;swap editor local variables (40/80 mode change)
;	jmp window	;set top left or bottom right (.c) of window

_spare:	.byte $ff,$ff,$ff

; GLOBAL ABSOLUTE SCREEN EDITOR DECLARATIONS

cr    = 13
space = 32
quote = 34

swapbeg:
scbot:  .byte 0
sctop:  .byte 0
sclf:   .byte 0
scrt:   .byte 0
columns:.byte 0     ; Maximum Number of Screen Columns
datax:  .byte 0     ; Current Character to Print
tcolor: .byte 0     ; saved attribute to print ('insert' & 'delete')
insflg: .byte 0     ; Auto-Insert Mode Flag
scroll: .byte 0     ; disables  screen scroll, line linker
swapend:

mode:   .byte 0     ; 40/80 Column Mode Flag
graphm: .byte 0     ; text/graphic mode flag
charen:	.byte 0     ; ram/rom vic character character fetch flag (bit-2)
pause:  .byte 0     ; ;<ctrl>-S flag
kyndx:  .byte 0     ; Pending Function Key Flag
keyidx: .byte 0     ; Index Into Pending Function Key String
curmod: .byte 0     ; VDC Cursor Mode (when enabled)
vm1:    .byte 0     ; VIC Text Screen/Character Base Pointer
vm2:    .byte 0     ; VIC Bit-Map Base Pointer
vm3:    .byte 0     ; VDC Text Screen Base
vm4:    .byte 0     ; VDC Attribute Base
lintmp: .byte 0     ; temporary pointer to last line for LOOP4
curcol: .byte 0     ; vdc cursor color before blink
split:  .byte 0     ; vic split screen raster value
bitmsk: .byte 0     ; temporary for TAB & line wrap routines
saver:  .byte 0     ; yet another temporary place to save a register
tabmap: .res  10
bitabl: .res  4

keysiz:	.byte 0		;programmable key variables
keylen:	.byte 0         ;
keynum:	.byte 0		;
keynxt:	.byte 0		;
sedt1:
keybnk:	.byte 0		;
sedt2:
keytmp:	.byte 0		;

pkynum	= 10		;number of definable keys  (f1-f8, <shft>run, help)
pkybuf:	.res pkynum	;programmable function key lengths table
pkydef:	.res 256-pkynum	;programmable function key strings

swapout:.res 32
swapmap:.res 32

lstchr = DATA

.include "vdc_ed1.inc"
.include "vdc_ed6.inc"
.include "vdc_routines.inc"
.include "vdc_ed7.inc"

mainend:

