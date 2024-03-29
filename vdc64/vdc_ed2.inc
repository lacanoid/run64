;	.page
;	.subttl  ed2  scroll routines  (05/06/85)


;///////////////   S C R O L L    R O U T I N E S   \\\\\\\\\\\\\\\\\\


scrdwn:			;///////// scroll down \\\\\\\\\
	ldx LSXP
	bmi @sc1	;skip if new line flag already set
	cpx TBLX
	bcc @sc1	;skip if old line is below scroll area
	inc LSXP	;else inc start line number
@sc1:
	ldx scbot	;scroll down, start bottom
@sc2:
	jsr scrset	;set 'pnt' to line
	ldy sclf
	cpx TBLX	;test if at destination line
	beq @sc3	;...done if yes
	dex		;point to previous line as source
	jsr getbt1
	inx
	jsr putbt1	;move continuation byte
	dex
	jsr movlin	;move one line
	jmp @sc2
@sc3:
	jsr clrln	;set line to blanks
	jmp setbit	;mark as continuation line

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
scrup:			;//////////// scroll up \\\\\\\\\\\\\\\
	ldx sctop
@scu1:
	inx
	jsr getbt1	;find first non-continued line
	bcc scru15
	cpx scbot
	bcc @scu1
	ldx sctop
	inx
	jsr clrbit	;clear to only scroll 1 line

scru15:			;////// entry from 'dline'
	dec TBLX
	bit LSXP
	bmi @scu2	;no change if already new line
	dec LSXP	;move input up one

@scu2:
	ldx sctop
	cpx sedt2
	bcs @scu3
	dec sedt2	;in case doing insert

@scu3:
	jsr scr10	;scroll
	ldx sctop
	jsr getbt1
	php
	jsr clrbit	;make sure top line is not continuation
	plp
	bcc @scu4	;done if top line off
	bit scroll	;logical scroll?
	bmi scrup	;no - keep scrolling
@scu4:
	rts


scr10:
	jsr scrset
	ldy sclf
	cpx scbot	;at last line?
	bcs @scu5	;yes
	inx			;point to next line
	jsr getbt1
	dex
	jsr putbt1	;move continuation byte
	inx
	jsr movlin	;move one line
	jmp scr10

@scu5:
	jsr clrln	;make last line blank
	lda #$7f
	sta colm
	lda rows	;scan keyboard
	cmp #$df	;check for slow-scroll key (C=)
	bne slorts	;...branch if not	

;	.page

	ldy #0
slowmo:
	nop		;delay
	dex
	bne slowmo
	dey
	bne slowmo
slorts:
	rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
movlin:			;///// move line in .x to 'pnt' (color to 'user')
	bit mode
	bmi movl80	;...branch if 8563 device
	lda ldtb2,x
	sta sedeal	;set up source pointers
	sta sedsal
	lda ldtb1,x
	and #$03
	ora ldtb1_sa
	sta sedsal+1
	and #$03
	ora #>viccol
	sta sedeal+1

@mo1:
	lda (sedsal),y	;move character byte
	sta (PNT),y
	lda (sedeal),y	;move color byte
	sta (USER),y
	cpy scrt	;done a whole line?
	iny
	bcc @mo1	;no
	rts

;	.page
movl80:			;copy 8563 line in current window...
	stx sav80a	;save line pointer
	sty sav80b	;save colm pointer (left window margin)

	ldx #24
	jsr vdcin
	ora #$80	;set 'copy' bit
	jsr vdcout
	jsr getpnt	;setup 8563 destination address to PNT + .Y
	ldx sav80a	;calculate absolute source = 2*(line tbls,x) + colm ptr
	lda ldtb2,x
	asl a
	sta sedsal	; (2*(line tbls,x))
	lda ldtb1,x
	and #$03
	rol a
	ora vm3
	sta sedsal+1
	ldx #32
	clc
	tya		;column pointer
	adc sedsal
	sta sedsal	;save source lo
	lda #0
	adc sedsal+1
	sta sedsal+1
	jsr vdcout	;source hi
	inx
	lda sedsal
	jsr vdcout	;source lo

	sec
	ldx scrt	;calculate # bytes to move = right margin - colm ptr + 1
	inx
	txa
	sbc sav80b
	sta sav80b	;save byte count
	ldx #30
	jsr vdcout	;copy characters

	ldx #32		;now move attributes...
	lda sedsal+1	;source hi
	and #$07
	ora vm4		;make text pointer into an attribute pointer
	jsr vdcout
	inx
	lda sedsal	;source lo
	jsr vdcout
	jsr getusr	;setup 8563 destination address to USER + .Y
	lda sav80b	;byte count
	ldx #30
	jsr vdcout	;copy attributes
	ldx sav80a	;restore .x
	rts
;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
clrln:			;///// enter here to clear entire line in .x
	ldy sclf
	jsr clrbit	;make sure non-continued line

clrprt:			;///// enter here to clear line in .x starting at .y
	jsr scrset
	bit mode
	bmi clrl80	;...branch if 8563 device
	dey
@cl1:
	iny
	lda #space
	sta (PNT),y	;print space
	lda COLOR
	sta (USER),y	;update color ram
	cpy scrt
	bne @cl1
	rts



clrl80:			;blank (fill) line in current window...
	stx sav80a	;save line pointer
	sty sav80b	;save colm pointer

	ldx #24
	jsr vdcin
	and #$7f	;set 'fill' bit
	jsr vdcout

	ldx #18		;calculate absolute destination = PNT + colm ptr
	clc
	tya		;column pointer
	adc PNT
	pha
	sta clr_ea_lo	;?????  kludge  ????????????????????????????????????????
	lda #0
	adc PNT+1
	sta clr_ea_hi	;?????  kludge  ????????????????????????????????????????
	jsr vdcout	;destination hi
	inx
	pla
	jsr vdcout	;destination lo

	lda #space	;character fill data
	jsr vdcput

	sec
	lda scrt	;calculate # bytes to fill = right margin - colm ptr
	sbc sav80b
	pha			; (save byte count for attribute fill)
	beq @cl10	;...branch if done- only one column

	tax		;?????  save byte count
	sec		;?????  add:  sa + byte count + 1  =  ea
	adc clr_ea_lo	;?????
	sta clr_ea_lo	;?????
	lda #0		;?????
	adc clr_ea_hi	;?????
	sta clr_ea_hi	;?????
	txa		;?????
	jsr clr_kludge	;?????  do block fill

@cl10:
	ldx #18		;now fill attributes
	clc
	tya		;column pointer
	adc USER
	pha
	lda #0
	adc USER+1
	jsr vdcout	;destination hi
	inx
	pla
	jsr vdcout	;destination lo

	lda clr_ea_hi	;????? adjust ea for attribute area
	and #$07	;?????
	ora vm4		;?????
	sta clr_ea_hi	;?????

	lda COLOR	;color fill data
	and #$8f	;strip off rvs, flash & underline attributes
	jsr vdcput

	pla		;recall byte count
	beq @cl20		;...branch if done- only one column
	jsr clr_kludge	;send byte count

@cl20:
	ldx sav80a	;return registers as we did with 40-col fill
	ldy scrt
	rts



;  The following crap is necessary thanks to our brilliant engineering
;  team, creators of the finest semi-functional devices ever made!



clr_kludge_1:
	lda #1			;????? byte count for kludge loop


clr_kludge:
	ldx #30
	jsr vdcout	;send byte count (actual fill starts now)


@clrk10:
	bit vdcadr		;????? wait if 8563 busy
	bpl @clrk10		;?????
	ldx #18			;?????
	jsr vdcin		;????? compare msb's: they should match
	cmp clr_ea_hi		;?????
	bcc clr_kludge_1	;????? nope- do again by 1 until they match
	ldx #19			;?????
	jsr vdcin		;????? compare lsb's: they should match
	cmp clr_ea_lo		;?????
	bcc clr_kludge_1	;????? nope- do again by 1 until they match
	rts			;?????

;.end
