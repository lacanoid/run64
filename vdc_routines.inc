;	.page
;	.subttl  80-column editor routines  (01/17/85)

swap:
	sta lstchr	;<escape> entry: must update 'lstchr' BEFORE swap!


swapper:
	ldx #swapend-swapbeg
@s1:	
	ldy swapout,x
	lda swapbeg,x	;swap local editor variables
	sta swapout,x
	tya
	sta swapbeg,x
	dex
	bpl @s1

	ldx #13
@s2:	
	ldy swapmap,x	;swap tab map and line wrap tables
	lda tabmap,x
	sta swapmap,x
	tya
	sta tabmap,x
	dex
	bpl @s2

	lda mode	;toggle 40/80 device mode flag
	eor #$80
	sta mode
swrts:	rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
cursor:	bit mode	;move the 8563 cursor
	bpl swrts	;...branch if 80-col swapped out & rts
	ldx #14		;update the 8563 hardware cursor position
	clc
	lda PNT
	adc PNTR
	pha		;cursor position low
	lda PNT+1
	adc #0
	jsr vdcout	;cursor position high
	inx
	pla
	jmp vdcout	;& rts

crsron:	
	bit mode	;enable the cursor on current screen
	bpl crsr40	;...branch if 40-column screen active
	jsr scolor
	ldy PNTR	;set 'USER' & .y to current position
	jsr getusr	;read attribute byte at cursor
	jsr vdcget
	sta curcol	;save it
	and #$f0
	sta saver	;strip off COLOR but save other attributes
	jsr getusr	
	lda COLOR	;get current attribute byte
	and #$0f	;strip off special attributes but save COLOR
	ora saver	;merge existing specials with current COLOR
	jsr vdcput	;make cursor blink in current COLOR

crsrdo:	ldx #10		;//////entry from 'escape' functions here
	lda curmod	;8563 cursor mode
	jmp vdcout	;enable 80-column hardware cursor & rts

crsr40:	lda #0
	sta blnsw	;enable 40-column software cursor
	rts

crsrof:	bit mode	;disable the cursor on current screen
	bpl @c1		;...branch if 40-column screen active
	jsr getusr	;'USER' & .y already point to cursor position
	lda curcol
	jsr vdcput	;restore attribute byte under cursor
	ldx #10
	lda #$20
	jmp vdcout	;disable 80-column hardware cursor & rts

@c1:
	sta blnsw	;disable 40-column software cursor (.a>0)
	lda BLNON
	bpl @c2		;...branch if cursor not visible at this time
	and #$40
	sta BLNON	;flag vic cursor as not visible
	lda GDBLN	;get saved character
	ldx GDCOL	;get saved COLOR
	jsr disply	;restore corrected screen data at cursor position
@c2:
	rts
;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

vdcput:	ldx #31		;update data register

vdcout:	stx vdcadr	;update 8563 register in .x with data in .a

vdc_so:	bit vdcadr	;////// entry to write next sequential byte
	bpl vdc_so
	sta vdcdat
	rts



vdcget:	ldx #31		;read data register

vdcin:	stx vdcadr	;read 8563 register in .x, pass data in .a

vdc_si:	bit vdcadr	;////// entry to read next sequential byte
	bpl vdc_si
	lda vdcdat
	rts



getpnt:			;setup 8563 update registers (18,19) with  PNT + .Y
	ldx #18		;calculate absolute destination = PNT + colm ptr
	clc
	tya		;column pointer
	adc PNT
	pha
	lda #0
	adc PNT+1
	jsr vdcout	;8563 text screen memory address hi
	pla
	inx
	jmp vdcout	;8563 text screen memory address lo & rts



getusr:			;setup 8563 update registers (18,19) with  USER + .Y
	ldx #18		;calculate absolute destination = USER + colm ptr
	clc
	tya		;column pointer
	adc USER
	pha
	lda #0
	adc USER+1
	jsr vdcout	;8563 attribute memory address hi
	pla
	inx
	jmp vdcout	;8563 attribute memory address lo & rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
init80:
	lda #<vicchr	;set up pointers to vic character rom
	ldy #>vicchr
	sta sedsal
	sty sedsal+1

	ldx #18
	lda #>vdcchr
	jsr vdcout	;initialize 8563 update register high
	inx
	lda #<vdcchr
	jsr vdcout	;low

	ldy #0
@i1:	
	ldx #14		;bank where vic character rom can be read
	lda #sedsal	;vector into character rom (.y is the index)
	jsr _fetch	;get a byte
	jsr vdcput
	iny
	cpy #8
	bcc @i1		;...loop until character is transfered

	lda #0
@i2:	
	jsr vdcput	;pad with nulls to fill out 8563 chr definition
	dey
	bne @i2		;...loop until done a character

	clc
	lda sedsal	;increment pointer to next character in rom
	adc #8
	sta sedsal
	bcc @i1
	inc sedsal+1
	lda sedsal+1
	cmp #>vicchr+$10
	bcc @i1		;...loop until done all characters

	rts
;.end