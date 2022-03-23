; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

feature_scnkey=0   ; keyboard scan routine
feature_pfkey=0    ; programmable function keys
feature_irq=1      ; raster interrupt service routine

feature_irq_tapemotor=0      ; raster tape motor stuff
feature_bgcolor=1            ; background color setter RVS+CLR

vdc_colors=1       ; use new vdc colors

org = $8000

UDTIM     = $FFEA
SCNKEY    = $FF9F

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.
resultRegister = $d7ff

        ; autodetect vdc version and exit if not found
        jsr detect
        lda vdc_config
        beq perror
        ; copy editor code into place
        ldx #>(mainend-main)
        inx
        lda #0
        jsr LINPRT 

        ldx #>(mainend-main)
        ldy #0
@l1:    lda data,Y
@l2:    sta org,y
        iny
        bne @l1
        inc @l1+2
        inc @l2+2
        dex 
        bpl @l1
        ; initialize
        jsr org
        jsr banner
        rts

detect: ; detect VDC
        ldy #0
        ldx #$1c
        stx vdcadr
@d1:
        bit vdcadr
        bmi @d2
        dey
        bne @d1
        ; no vdc
        rts
@d2:    ; vdc detected
        lda vdcdat
        sta vdc_config
        rts

perror:
        ldx #0
@pe1:   lda emsg, x
        beq @pe2
        jsr CHROUT
        inx
        bne @pe1
@pe2:
        rts

emsg:   .asciiz "NO VDC. TRY C128."

banner: ; print banner and info
        lda COLOR
        sta T1
        ldx #0
@m1:    lda msg, x
        beq @m2
        jsr CHROUT
        inx
        bne @m1
@m2:
        ldx vdc_config
;        beq @m_16k
;@m_64k:
;        ldx #64
;        nop3
;@m_16k:
;        ldx #16
        lda #0
        jsr LINPRT

;        lda #'K'
;        jsr CHROUT
        lda #' '
        jsr CHROUT

@m3:
        ldx #<mode
        lda #>mode
        jsr LINPRT

        lda T1
        sta COLOR

exit:
        lda #0
        sta resultRegister

;        jmp ($a000)

        rts

msg:    .byte 7
        .byte $12,$1c,$20,$96,$20,$9e,$20,$99,$20,$9a,$20,$9c,$20,$92,$05
        .asciiz " VDC64 0.3 "

; --------------------------
data:
        .org org
main:
        jmp configure

; --------------------------

vicchr	= $d000	        ;vic character rom
vicreg  = $d000         ;vic registers
viccol	= $d800		;vic color nybbles
vicscn  = VICSCN

sidreg	= $d400		;sid registers

vdcadr	= $d600		;8563 address register
vdcdat	= $d601 	;8563 data    register

vdcscn	= $0000		;8563 80-column screen	(2KB)
vdccol	= $0800		;8563 attribute area	(2KB)
vdcchr	= $2000		;8563 character ram	(4KB: 256 chrs, 8x16)

cia1    = $dc00
colm    = cia1
rows    = cia1+1

cia2    = $dd00
d2pra   = cia2

EDITOR:
;////////////////   E D I T O R     J U M P     T A B L E   \\\\\\\\\\\\\\\\\
;	jmp cint	;initialize editor & screen
	jmp disply	;display character in .a, color in .x
	jmp lp2		;get a key from irq buffer into .a
	jmp loop5	;get a chr from screen line into .a
	jmp print	;print character in .a
	jmp scrorg	;get size of current window (rows,cols) in .x, .y
	jmp scnkey	;scan keyboard subroutine
	jmp repeat	;repeat key logic & 'ckit2' to store decoded key
	jmp plot	;read or set (.c) cursor position in .x, .y
	jmp cursor	;move 8563 cursor subroutine
	jmp escape	;execute escape function using chr in .a
	jmp keyset	;redefine a programmable function key
	jmp irq		;irq entry
	jmp init80	;initialize 80-column character set
	jmp swapper	;swap editor local variables (40/80 mode change)
	jmp window	;set top left or bottom right (.c) of window

_spare:	.byte $ff,$ff,$ff

; GLOBAL ABSOLUTE SCREEN EDITOR DECLARATIONS

cr    = 13
esc   = 27
space = 32
quote = 34

sedsal  = $D9
sedeal  = $DB

swapbeg:
pnt:    .word 0     ; = PNT
user:   .word 0     ; = USER

scbot:  .byte 0
sctop:  .byte 0
sclf:   .byte 0
scrt:   .byte 0

lsxp:   .byte 0     ; = LSXP
lstp:   .byte 0     ; = LSTP
indx:   .byte 0     ; = INDX

tblx:   .byte 0     ; = TBLX
pntr:   .byte 0     ; = PNTR

lines:  .byte 0     ; maximum number of screen lines
columns:.byte 0     ; maximum number of screen columns

datax:  .byte 0     ; Current Character to Print
lstchr: .byte 0     ; previous character printed  (for <esc> test)
color:  .byte 0     ; = COLOR     ; current foreground color
tcolor: .byte 0     ; saved attribute to print ('insert' & 'delete')

rvs:    .byte 0     ; = RVS
qtsw:   .byte 0     ; = QTSW
insrt:  .byte 0     ; = INSRT
insflg: .byte 0     ; Auto-Insert Mode Flag

locks:  .byte 0     ; disables  <c=><shift>,   <ctrl>-S
scroll: .byte 0     ; disables  screen scroll, line linker
beeper: .byte 0     ; disables  <ctrl>-G
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
sav80a: .byte 0     ; temporary for 80-col routines
sav80b: .byte 0     ; temporary for 80-col routines
curcol: .byte 0     ; vdc cursor color before blink
split:  .byte 0     ; vic split screen raster value
bitmsk: .byte 0     ; temporary for TAB & line wrap routines
saver:  .byte 0     ; yet another temporary place to save a register
tabmap: .res  10
bitabl: .res  4

init_status: .byte 0 ; flags reset vs. nmi status for initialization routines
vdc_config:  .byte 0 ; vdc memory & version (autodetected)

ctlvec: .word 0     ; editor: print 'contrl' indirect
shfvec: .word 0     ; editor: print 'shiftd' indirect
escvec: .word 0     ; editor: print 'escape' indirect
keyvec: .word 0     ; editor: keyscan logic  indirect
keychk: .word 0     ; editor: store key indirect

ldtb1_sa:  .byte 0      ; high byte of sa of vic screen (use with vm1 to move screen)
clr_ea_lo: .byte 0      ; ????? 8563 block fill kludge
clr_ea_hi: .byte 0      ; ????? 8563 block fill kludge

swapout:.res 32
swapmap:.res 32

keysiz:	.byte 0		;programmable key variables
keylen:	.byte 0         ;
keynum:	.byte 0		;
keynxt:	.byte 0		;
sedt1:
keybnk:	.byte 0		;
sedt2:
keytmp:	.byte 0		;

.if feature_pfkey=1
decode: .res  12    ; vectors to keyboard matrix decode tables
pkynum	= 10		;number of definable keys  (f1-f8, <shft>run, help)
pkybuf:	.res pkynum	;programmable function key lengths table
pkydef:	.res 256-pkynum	;programmable function key strings
.endif


r6510  = 1
mmureg = r6510

.include "vdc_ed1.inc"
.include "vdc_ed2.inc"
.include "vdc_ed3.inc"
.include "vdc_ed4.inc"
.include "vdc_ed5.inc"
.include "vdc_ed6.inc"
.include "vdc_routines.inc"
.include "vdc_ed7.inc"

; --- come c128 like memory management

fetch:
        lda mmureg
        stx mmureg
        tax
        .byte $b1  ; lda (zp),y
fetvec:
        .byte $66
        stx mmureg
        rts

; indirect fetch (.a),y from bank .x
; I: .a = zp pointer, .x = bank, .y = index 
; O: .a = data, .x = trash
indfet:
        sta fetvec
        lda mmucfg,X
        tax
        jmp fetch

; get mmu configuration
; I: .x = bank
; O: .a = mmu configuration
getcfg:
        lda mmucfg,x
        rts

mmucfg:
        ; bank 0  - 12 = ram only
        ; bank 13 - ram + I/O
        ; bank 14 - rom + chargen
        ; bank 15 - rom + I/O
        .byte 0, 0, 0, 0
        .byte 0, 0, 0, 0
        .byte 0, 0, 0, 0
        .byte 0, 5, 3, 7

; -- hook into system

vdcsetcolors:
        lda COLOR
        and #$0F
        tay 
        lda coladj,y
        sta COLOR

        ldx #$1a
        lda BGCOL0
        and #$0F
        tay 
        lda coladj,y
        jsr vdcout

        rts

configure:
        lda COLOR
        pha
                jsr cint
        pla
        sta COLOR

        jsr vdcsetcolors

        lda #<new_basin
	sta IBASIN
	lda #>new_basin
	sta IBASIN + 1

        lda #<new_bsout
	sta IBSOUT
	lda #>new_bsout
	sta IBSOUT + 1

.if feature_irq=1
        sei

        lda #<new_irq
        sta CINV
        lda #>new_irq
        sta CINV+1

        jmp @cf2

        lda #$7f        ; disable CIA interrupts
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d


        lda IRQMASK     ; enable VIC raster interrupt
        ora #1
        sta IRQMASK
        lda #150         ; set initial raster line
        sta RASTER
        lda SCROLY
        and #$7f        ; raster hight bit
        sta SCROLY

@cf2:
        cli
        rts

new_irq:
;        jsr EDITOR+$24   
        jmp $EA31       ; default handler in ROM

        lda mmureg
        pha
        CLD
        ; editor handles split screen and calls SCNKEY and BLINK
        jsr EDITOR+$24   
        bcc @nirq9              ; split screen interrupt
        jsr UDTIM               ; update clock
        lda cia2+$0d            ; clear CIA2
        lda init_status         ; check for animations
        lsr
        bcc @nirq9
        jsr animate
@nirq9:
; c64   $EA61      same in c64 rom + SCNKEY
; c128  $FF33
        pla
        jsr tapemotor
        sta mmureg
; c64   $EA81
        pla
        tay
        pla
        tax
        pla
        rti

CAS1 = $C0
tapemotor:  ; handle tape motor
.if feature_irq_tapemotor=1
        pha
        and #$10
        beq @tm3 
        ldy #0
        sty CAS1
        pla
        pha
        ora #$20
        bne @tm9
@tm3:
        lda CAS1
        bne @tm9
        pla
        and #%011111
@tm9:
.endif
        rts

animate:        ; run basic sprite animations
.endif             ; feature_irq
        rts


new_bsout:
	sta DATA
	pha
	lda DFLTO
	cmp #3
	bne @nbo1
	txa
	pha
	tya
	pha
	lda DATA
	jsr print
	pla
	tay
	pla
	tax
	pla
	clc
	cli ; XXX user may have wanted interrupts off!
	rts
@nbo1:	jmp $F1D5 ; original non-screen BSOUT
        
new_basin:
	lda DFLTN
        bne @nbi1
        ; input from dev = 0

        lda PNTR
        sta LSTP
        lda TBLX
        sta LSXP

        jmp loop5

@nbi1:  ; input from dev != 0
	jmp $F157 ; original non-screen BASIN

mainend:

