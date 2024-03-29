;	.page
;	.subttl  ed4  print routines  (04/06/85)

; //////////////////  P R I N T   C H A R A C T E R   \\\\\\\\\\\\\\\\\\\\\\

print:			;print character in .a on the screen & rts to 'loop2'
	sta datax	;save a copy of character to print
;	sta DATA
	pha		;save all registers
	txa
	pha
	tya
	pha

@pr10:
	lda pause	;is there a pause (<ctrl>-S) in effect?
	bne @pr10	;...loop if so (irq key routine must clear it @ckit2)
	sta CRSW

loop2v	= loop2-1

	lda #>loop2v	;push 'loop2' onto stack for common return mechanism
	pha
	lda #<loop2v
	pha

	ldy PNTR	;screen column to print to
	lda datax	;character to print
	cmp #cr 	;is it <cr> or <shift><cr>?
	beq prtcr	;...branch if so
	cmp #cr+$80
	beq prtcr

	ldx lstchr	;was previous character an <escape>?
	cpx #esc
	bne @pr20	;...branch if not
	jmp escchr	;yes- go to escape handler & rts to 'loop2'

@pr20:
	tax			;sets processor status per current character
	bpl @pr30	;...branch if it was not shifted
	jmp shfchr	;yes- go process shifted character

@pr30:
	cmp #space
	bcc ctlchr	;...branch if it was <ctrl> character

@pr40:
	cmp #$60	;convert to cbm screen code
	bcc @pr50
	and #$df 	;convert ($60-$7f to $40-$5f)
	.byte $2c
@pr50:
	and #$3f	;convert ($40-$5f to $00-$1f)

	jsr qtswc	;if quote char, toggle quote switch
	jmp nxt3 	;put character on screen & do rts to 'loop2'
;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
prtcr:			;print a <cr><lf>
	jsr fndend	;find the end of the current line
	inx
	jsr clrbit	;set next line as non-continued
	ldy sclf 	;point to first column of next line
	sty PNTR
	jsr nxln 	;set up next line & fall thru to 'togm'



toqm:			;reset all editor modes
	lda COLOR
	and #$cf
	sta COLOR	;reset 8563 underline & flash modes
	lda #0
	sta INSRT	;reset insert mode
	sta RVS		;reset reverse mode
	sta QTSW	;reset quote mode
	rts



ctltbs:
	.byte $02,$07,$09,$0a,$0b,$0c,$0e
	.byte $0f,$11,$12,$13,$14,$18,$1d

ctltbe:			;dispatch table for <ctrl> characters

	.word undron-1	; b ($02) set underline mode (8563)
	.word beep-1	; g ($07) bell
	.word tab-1	    ; i ($09) tab
	.word lfeed-1	; j ($0a) line feed
	.word lock-1	; k ($0b) lock out <C=><shift>
	.word unlock-1	; l ($0c) unlock   <C=><shift>
	.word lower-1	; n ($0e) lower case
	.word flshon-1	; o ($0f) set flash mode (8563)
	.word crsrdn-1	; q ($11) cursor down
	.word RVSon-1	; r ($12) set reverse field mode
	.word homtst-1	; s ($13) home cursor
	.word delete-1	; t ($14) delete
	.word tabset-1	; x ($18) toggle tab stop
	.word crsrrt-1	; ] ($1d) cursor right

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
ctlchr:	jmp (ctlvec)	;'contrl' indirect

contrl:			;print a <ctrl> character & rts to 'loop2' always
	cmp #esc
	beq ctlrts	;...branch if <escape> & ignore

	ldx INSRT	;if insert or quote mode, show character as RVS field 
	bne @ctl1	;...branch if insert mode
	cmp #$14
	beq @ctl2	;...branch if <delete> to allow them in quote mode
	ldx QTSW
	beq @ctl2		;...branch if not quote mode
@ctl1:
	ldx #0
	stx datax	;squash 'lstchr' (eg: used to detect double <home>'s)
	jmp nc3		;print character in reverse field

@ctl2:
	ldx #ctltbe-ctltbs-1
@ctl3:
	cmp ctltbs,x	;test if character is a functional <ctrl> character
	beq ctlexe	;...yes- go handle it
	dex
	bpl @ctl3

colchk:			;////// 'shiftd' exits thru here too
	ldx #15		;test if character is a COLOR
@cc1:
	cmp coltab,x
	beq @cc2	;...it is
	dex
	bpl @cc1
	rts		;an unrecognized character...ignore it, rts to 'loop2'

@cc2:
	bit mode
	bmi @cc3
	stx COLOR	;set current foreground COLOR
	rts		;to 'loop2'

@cc3:
	lda COLOR	;set 8563 COLOR (convert to c64 COLORs)
	and #$f0	;preserve special attributes
	ora coladj,x
	sta COLOR
ctlrts:
	rts


ctlexe:
	txa
	asl a		;index into ctrl dispatch table
	tax
	lda ctltbe+1,x
	pha
	lda ctltbe,x
	pha
	rts		;do <ctrl> function, rts to 'loop2'

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
shfchr:	jmp (shfvec)	;'shiftd' indirect

shiftd:			;process shifted keycodes & return to 'loop2'
	and #$7f 	;mask off msb
	cmp #$20 	;immediate function key?
	bcc @sh2		;yes

	cmp #$7f	;pi?
	bne @sh1
	lda #$5e	;yes- translate it

@sh1:
	jmp nxt33	;print it

@sh2:
	ldx QTSW 	;if quote mode,  show character in RVS field
	beq @sh4		;...branch not quote mode

@sh3:
	ora #$40 	;make it shifted
	jmp nc3		;make it reversed and print it

@sh4:
	cmp #$14 	;<insert>?  (must check before 'INSRT' flag test!)
	bne @sh5
	jmp insert

@sh5:
	ldx INSRT	;if insert mode, show character in RVS field
	bne @sh3		;...branch if insert mode

	cmp #$11 	;<crsr-up>?
	beq crsrup

	cmp #$1d	;<crsr-lf>?
	beq crsrlf

	cmp #$0e 	;'set upper case'?
	beq upper

	cmp #$12 	;<RVS-off>?
	bne @sh6
	jmp RVSoff

@sh6:
	cmp #$02	;'disable underline'?
	bne @sh7
	jmp undrof

@sh7:
	cmp #$0f	;'disable flash'?
	bne @sh8
	jmp flshof

@sh8:
	cmp #$13 	;<clr>?
	bne @sh9
	jmp clsr

@sh9:
	ora #$80 	;restore msb
	bne colchk	;(always) test for COLOR & rts to 'loop2'

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
crsrrt:
	jsr nxtchr	;cursor right
	bcs crsrw1	;branch if wrap
	rts



crsrdn:
	jsr nxln 	;cursor down

crsrw1:
	jsr getbit	;a wrapped line?
	bcs crsrok
	sec
	ror LSXP 	;flag we left line

crsrok:	clc
crsrts:	rts		;return to 'loop2' (except 'crsrlf' call from 'delete')



crsrup:
	ldx sctop	;cursor up
	cpx TBLX 	;at top of window?
	bcs crsrts	;yes...do nothing

crsrw2:
	jsr crsrw1	;about to wrap?
	dec TBLX 	;up a line
	jmp stupt	;setup pointers & return to 'loop2' (unless 'delete')



crsrlf:
	jsr bakchr	;cursor left (////// called also by 'delete')
	bcs crsrts	;abort if at top left
	bne crsrok	;no- exit
	inc TBLX
	bne crsrw2	;(always) go set flag if needed

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
lower:			;set lower character set
	bit mode
	bmi lower_80	;...branch if 8563 mode
	lda vm1 	;get character base
	ora #$02	;set VIC cb11: (point to lower case)
	bne uprts	;always

lower_80:
	lda COLOR	;set 8563 attribute ALT bit
	ora #$80
	sta COLOR
	rts


upper:			;set upper character set
	bit mode
	bmi upper_80	;...branch if 8563 mode
	lda vm1		;get character base
	and #$fd	;clear VIC cb11: (point to upper case)

uprts:	
	sta vm1		;change will occur at next display frame
	rts		;returns to 'loop2'


upper_80:
	lda COLOR	;clear 8563 attribute ALT bit
	and #$7f
	sta COLOR
	rts



lock:
	lda #$80 	;lock keyboard in current mode
	ora locks 	;set lock bit
	bmi unlrts	;always



unlock:
	lda #$7f 	;unlock keyboard
	and locks	;clear lock bit

unlrts:
	sta locks
	rts		;return to loop2



homtst:
	lda lstchr
	cmp #$13	;is this the 2nd consecutive <home>?
	bne @ho1	;no
	jsr sreset	;yes...reset window to full screen
@ho1:
	jmp home	;home cursor

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
RVSoff:
	lda #0		;turn off reverse field mode
	.byte $2c
RVSon:
	lda #$80	;turn on reverse field mode
	sta RVS
	rts



undron:
	lda COLOR	;enable underline attribute (has effect on 8563 only)
	ora #$20
	sta COLOR
	rts

undrof:
	lda COLOR	;disable underline attribute
	and #$df
	sta COLOR
	rts


flshon:
	lda COLOR	;enable flash attribute (has effect on 8563 only)
	ora #$10
	sta COLOR
	rts

flshof:
	lda COLOR	;disable flash attribute
	and #$ef
	sta COLOR
	rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
insert:			;insert one character on screen
	jsr savpos	;save column & row position
	jsr fndend	;move to last char on the line
	cpx sedt2	;last row equal to starting row?
	bne @in1	;no - skip ahead
	cpy sedt1	;is last position before starting position?
@in1:
	bcc @in3	;yes - no need to move anything
	jsr movchr	;move to next char position
	bcs @in4	;abort if scroll needed but disabled
@in2:
	jsr bakchr
	jsr get1ch	;move char forward 1 position
	jsr nxtchr
	jsr displt
	jsr bakchr
	ldx TBLX
	cpx sedt2	;at original position
	bne @in2
	cpy sedt1
	bne @in2	;no - loop until we are
	jsr blank	;insert a blank
@in3:
	inc INSRT	;add one to insert count
	bne @in4	;only count up to 255
	dec INSRT	; (notice we already did the actual insert though...)
@in4:
	jmp delout	;restore original position

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
delete:			;delete one character on screen
	jsr crsrlf	;move cursor back one position
	jsr savpos	;save column & row position
	bcs delout	;abort if at top left corner of window

deloop:
	cpy scrt 	;at right margin?
	bcc delchr	;no- skip ahead
	ldx TBLX
	inx
	jsr getbt1	;is next line a wrapped line?
	bcs delchr	;yes- continue with delete
	jsr blank	;no- blank last character

delout:
	lda sedt1	;restore column and row position (entry from 'insert')
	sta PNTR
	lda sedt2
	sta TBLX
	jmp stupt	;restore 'PNT', 'user'  & rts to 'loop2'

delchr:
	jsr nxtchr
	jsr get1ch	;get next character
	jsr bakchr	;move pointers back one position
	jsr displt	;display character
	jsr nxtchr	;set up for next character
	jmp deloop	;loop until end of line

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
tab:
	ldy PNTR	;tab function
@tab1:
	iny
	cpy scrt	;at rightmost side of window?
	bcs @tab2	;yes
	jsr tabget	;find next tabstop
	beq @tab1	;branch if not there yet
	bne @tab3
@tab2:
	ldy scrt	;put cursor at right margin
@tab3:
	sty PNTR
	rts

tabset:
	ldy PNTR
	jsr tabget	;toggle tabstop at current cursor position
	eor bitmsk
	sta tabmap,x
	rts



tabget:			;return <> if column in .y is a tabstop
	tya		;       .a returns bits, .x index to tabmap
	and #$07
	tax
	lda bits,x
	sta bitmsk
	tya
	lsr a
	lsr a
	lsr a
	tax
	lda tabmap,x
	bit bitmsk	;set = flag
	rts



tabclr:
	lda #0		;clear all tab stops
	.byte $2c

taball:
	lda #$80	;set default tab stops
	ldx #9
@ta1:
	sta tabmap,x
	dex
	bpl @ta1
tabrts:
	rts

;	.page
beep:
	bit beeper	;generate 'bell' tone for <ctrl>-G
	bmi tabrts	;...branch if disabled

.if 0
	ldy #0
@beep1:
	lda beeppar,Y
	tax
	iny
	lda beeppar,Y
	sta sidreg,x
	iny
	cpy #beeppar1-beeppar
	bne @beep1
.else
	lda #$0f
	sta sidreg+24	;set volume control
	ldy #$0b
	ldx #$00
	sty sidreg+5	;set envelope
	stx sidreg+6
	lda #$10
	sta sidreg+1	;set oscillator frequency
	lda #$70
	sta sidreg+4	;set waveform & ungate
	lda #$71
	sta sidreg+4	;gate it
.endif
	rts

beeppar:
	.byte 24,15			; volume
	.byte 5,$09,6,$00	; envelope
	.byte 2,$30     	; frequency
	.byte 4,$20     	; set waveform & ungate
	.byte 4,$21			; gate it
beeppar1:

lfeed:
	lda PNTR	;move to next logical line but retain current column pointer
	pha
	jsr fndend	;move to end of current logical line
	jsr nxln	;move down one physical line
	pla
	sta PNTR	;restore cursor column pointer
	rts

;.end
