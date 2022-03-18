;	.page
;	.subttl  ed6  editor subroutines  (08/15/85)

get1ch:			;get a character & its COLOR from text screen
	ldy PNTR	;get char/COLOR index

	bit mode
	bmi get80	;...branch if from 8563 screen

	lda (USER),y    ;get the COLOR
	sta tcolor
	lda (PNT),y     ;get the character
	rts



get80:
	jsr getusr	;setup 8563 memory address to attribute
	jsr vdcget	;read the attribute
	sta tcolor
	jsr getpnt	;setup 8563 memory address to character
	jsr vdcget	;read the character
	rts

;	.page
;  wrap table subroutines
;
getbit:
	ldx TBLX
getbt1:
	jsr bitpos	;get byte & bit positions
	and bitabl,x
	cmp #1		;make carry clear if zero
	jmp bitout




; putbit - set bit according to carry
;
putbit:
	ldx TBLX
putbt1:
	bcs setbit	;go if to mark as wrappped line




; clrbit - clear wrap bit
;
clrbit:
	jsr bitpos	;get byte & bit positions
	eor #$ff	;invert bit position
	and bitabl,x    ;clear bit
bitsav:
	sta bitabl,x
bitout:
	ldx bitmsk
	rts




; setbit  -  set bit to mark as wrapped line
;
setbit:
	bit scroll	;check for line-link disable
	bvs getbt1
	jsr bitpos	;get byte & bit position
	ora bitabl,x    ;set wrap bit
	bne bitsav	;always

;	.page
; bitpos - get byte & bit position of wrap bit
;          input - x = row number
;          output - x = byte number
;                   a = bit mask

bitpos:
	stx bitmsk
	txa
	and #$07	;get bit position
	tax
	lda bits,x	;get bit mask
	pha
	lda bitmsk
	lsr a
	lsr a		;shift to get byte position
	lsr a
	tax
	pla
	rts

;	.page
; ****** move to end/start of line
;
fndsol:
	ldy sclf	;will move to start of line...
	sty PNTR	;set to leftmost column


; ****** find beginning of line
;
fistrt:
	jsr getbit	;find start of current line
	bcc @fi1		;branch if found
	dec TBLX	;up a line
	bpl fistrt	;always
	inc TBLX	;whoops went too far

@fi1:	jmp stupt 	;set line base adr


; ****** find last non-blank char of line
;
; PNTR= column #
; TBLX= line #

fndend:
	inc TBLX
	jsr getbit	;is this line continued
	bcs fndend	;branch if so
	dec TBLX	;found it - compensate for inc TBLX
	jsr stupt
	ldy scrt	;get right margin
	sty PNTR	;point to right margin

@fn1:
	jsr get1ch
	ldx TBLX	;restore .x (if 8563 mode, 'get1ch' trashes .x)
	cmp #space
	bne @fn3		;yes
	cpy sclf	;are we at the left margin?
	bne @fn2		;no- keep going
	jsr getbit	;are we on a wrapped line?
	bcc @fn3		;no- get out

@fn2:
	jsr bakchr
	bcc @fn1		;ok- not at top left

@fn3:
	sty INDX	;remember this
	rts

;	.page
; ****** move to next char
;
; scroll if enabled, else wrap to top

nxtchr:
	pha
	ldy PNTR
	cpy scrt	;are we at the right margin?
	bcc @nx1	;branch if not

	jsr nxln	;point to next line
	ldy sclf	;point to first char of 1st line
	dey
	sec		;set to show moved to new line
@nx1:
	iny		;increment char index
	sty PNTR
	pla
	rts


; ****** backup one char
;
; wrap up and stop a top left

bakchr:
	ldy PNTR
	dey
	bmi @ba1
	cpy sclf	;are we at the left margin
	bcs @ba2	;no - past it

@ba1:
	ldy sctop
	cpy TBLX	;are we at top line last character?
	bcs @ba3		;leave with carry set
	dec TBLX	;else backup a line
	pha
	jsr stupt 	;set line base adr
	pla
	ldy scrt	;move cursor to right side

@ba2:
	sty PNTR
	cpy scrt	;set z-flag if moved to new line
	clc		;always clear
@ba3:
	rts


; ****** save row & column position
;
savpos:
	ldy PNTR
	sty sedt1
	ldx TBLX
	stx sedt2
	rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;  ///////// put a character on the screen \\\\\\\\\\\
;
;	enter 'disply' with .a= character,  .x= COLOR


blank:
	lda COLOR	;display a blank
	and #$8f	; (strip off rvs, underline & flash attributes)
	tax
	lda #space
	.byte $2c



displc:
	ldx COLOR	;use current fgnd COLOR
	.byte $2c



displt:
	ldx tcolor	;use saved COLOR



disply:
	tay		;save character to diplay
	lda #2
	sta BLNCT	;force a cursor blink

	jsr scolor	;setup COLOR pointers
	tya		;restore character
	ldy PNTR	;get cursor position


displ:
	bit mode
	bmi disp80	;...branch if 8563 screen

	sta (PNT),y	;put character on screen
	txa		;get COLOR
	sta (USER),y	;put the COLOR on screen
	rts


disp80:
	pha		;save character
	txa
	pha		;save COLOR
	jsr getusr	;setup COLOR byte pointer
	pla
	jsr vdcput	;put the COLOR on the screen
	jsr getpnt	;setup character byte pointer
	pla
	jmp vdcput	;put the character on the screen & rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	SCRORG		returns current window's size (maximum row & column #)
;
; entry:	nothing required.
;
; exit:		.x = maximum column number (# columns minus 1)
;		.y = maximum line   number (# lines   minus 1)
;		.a = maximum screen width  (# columns minus 1)
;


scrorg:			;return current window size  (maximum row & column #)
	sec
	lda scbot
	sbc sctop
	tay		;.y = # lines in current window - 1

	sec
	lda scrt
	sbc sclf
	tax		;.x = # columns in current window - 1

	lda columns	;.a = # columns in current screen - 1
	rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;	PLOT		reads or sets the cursor position within current window
;
; entry:	.c = 1	returns the cursor position (.y=column, .x=line)
;			relative to the current window origin (NOT screen origin).
;
;		.c = 0	sets the cursor position (.y=column, .x=line) relative
;			to the current window origin (NOT screen origin).
;
; exit:		.c = 1	error exit. the requested position was outside the
;			current window and NO CHANGE has been made (see SCRORG). .
;
;		.c = 0	normal exit. the cursor has been moved to the position
;			contained in .x & .y relative to window origin.
;

plot:
	bcs @pl30	;...branch to simply read the current position

	txa			;get line position relative to window origin
	adc sctop
	bcs @pl15
	cmp scbot
	beq @pl10	;...good if within window (position <= scbot)
	bcs @pl15	;...branch if error (.c=1)

@pl10:
	pha		;save
	clc
	tya		;get colm position relative to window origin
	adc sclf
	bcs @pl14
	cmp scrt
	beq @pl20		;...good if within window (position <= scrt)
	bcc @pl20
@pl14:
	pla
@pl15:
	rts		;error return (.c=1)

@pl20:
	sta PNTR	;set column position
	sta LSTP
	pla
	sta TBLX	;set line position
	sta LSXP
	jsr stupt	;position cursor there
	jsr cursor

@pl30:
	lda TBLX	;read current line position
	sbc sctop
	tax		;return cursor line # relative to window top
	sec
	lda PNTR	;read current column position
	sbc sclf
	tay		;return cursor column # relative to window left
	clc		;normal return
	rts

;	.page
;*************************************************************************
;
;	KEYSET - redefine a programmable function key
;
;	entry:	.a= pointer to new string adr (lo,hi,bank)
;		.x= key number (1-8)
;		.y= length of new string
;
;	exit:	.c= 0 if good,  1 if no room (no change made)
;
;**************************************************************************

keyset:
	dex
	stx keynum	;save key number (0-7)
	sty keysiz	;save string length
	sta fetvec	;setup address pointer
	tay
	ldx @ke2,y	;get bank
	jsr _config	;convert to actual mmu configuration
	sta keybnk

	ldx #pkynum	;(note: 'help' & <shft/run> strings too)
	jsr findky	;find end of all strings
	sta keylen	;save offset
	ldx keynum
	inx
	jsr findky	;find end of function key (beginning of next)
	sta keynxt	;save offset
	ldx keynum
	lda keysiz
	sec
	sbc pkybuf,x	;get new size - old size
	beq keyins	;skip if the same
	bcc @ke2	;skip if new is shorter
	clc
	adc keylen	;get new ending offset for all keys
	bcs keyerr	;wrapped? error if so...
	tax		;get destination address+1
	ldy keylen	;get source address+1

@ke1:
	cpy keynxt
	beq keyins	;done if all following keys have been moved
	dey		;expand key area
	dex		;move source to destination
	lda pkydef,y
	sta pkydef,x
	bcs @ke1


@ke2:
	adc keynxt	;get destination offset
	tax
	ldy keynxt	;get source address

@ke3:
	cpy keylen	;contract key area
	bcs keyins	;exit if moved all
	lda pkydef,y
	sta pkydef,x
	iny
	inx
	bcc @ke3		;always

;	.page
;  keyins  --  insert new key definition

keyins:
	ldx keynum	;get key number
	jsr findky	;get starting offset
	tax
	ldy keynum
	lda keysiz	;get new size
	sta pkybuf,y	;set new size
	ldy #0

@ki1:
	dec keysiz
	bmi keyrts	;exit - end of string
	stx keytmp
	ldx keybnk
	lda fetvec	; (already setup at 'keyset')
	sei
	jsr fetch	;lda (index),y:   move in new key def. from string
	cli
	ldx keytmp
	sta pkydef,x
	inx
	iny
	bne @ki1	;...always

keyrts:	clc		;good return

keyerr:	rts

findky:
	lda #0
	clc

@fi1:
	dex
	bmi @fi2
	adc pkybuf,x
	bcc @fi1
@fi2:
	rts

;.end
