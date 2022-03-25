length	= 40

linz0	= vicscn	;40 column screen lines
linz1	= linz0+length
linz2	= linz1+length
linz3	= linz2+length
linz4	= linz3+length
linz5	= linz4+length
linz6	= linz5+length
linz7	= linz6+length
linz8	= linz7+length
linz9	= linz8+length
linz10	= linz9+length
linz11	= linz10+length
linz12	= linz11+length
linz13	= linz12+length
linz14	= linz13+length
linz15	= linz14+length
linz16	= linz15+length
linz17	= linz16+length
linz18	= linz17+length
linz19	= linz18+length
linz20	= linz19+length
linz21	= linz20+length
linz22	= linz21+length
linz23	= linz22+length
linz24	= linz23+length

;	.page
ldtb2:			;screen lines low byte table
	.byte <linz0
	.byte <linz1
	.byte <linz2
	.byte <linz3
	.byte <linz4
	.byte <linz5
	.byte <linz6
	.byte <linz7
	.byte <linz8
	.byte <linz9
	.byte <linz10
	.byte <linz11
	.byte <linz12
	.byte <linz13
	.byte <linz14
	.byte <linz15
	.byte <linz16
	.byte <linz17
	.byte <linz18
	.byte <linz19
	.byte <linz20
	.byte <linz21
	.byte <linz22
	.byte <linz23
	.byte <linz24

ldtb1:			;screen lines high byte table
	.byte >linz0
	.byte >linz1
	.byte >linz2
	.byte >linz3
	.byte >linz4
	.byte >linz5
	.byte >linz6
	.byte >linz7
	.byte >linz8
	.byte >linz9
	.byte >linz10
	.byte >linz11
	.byte >linz12
	.byte >linz13
	.byte >linz14
	.byte >linz15
	.byte >linz16
	.byte >linz17
	.byte >linz18
	.byte >linz19
	.byte >linz20
	.byte >linz21
	.byte >linz22
	.byte >linz23
	.byte >linz24

;	.page

vectss:
	.word contrl	;print <ctrl> indirect
	.word shiftd	;print <shft> indirect
	.word escape	;print <esc>  indirect
.if feature_scnkey=1
	.word keylog	;keyscan logic indirect
	.word keyput	;key buffer indirect
.endif
vectse:


.if feature_scnkey=1
keycod:
	.word mode1	;decode matrix for normal keys
	.word mode2	;decode matrix for shifted keys (right keycap legends)
	.word mode3	;decode matrix for C= keys	(left  keycap legends)
	.word mode4	;decode matrix for control keys
	.word mode1	;decode matrix for alt keys	(none- default to norm)
	.word mode5	;decode matrix for caps lock
keyend:
.endif

;	.page
;//////   S C R E E N   &   E D I T O R   I N I T I A L I Z A T I O N   \\\\\\

cint:
	lda #$03
	ora d2pra	;set vic bank
	sta d2pra

.ifdef target_c128
	lda #$fb
	and r6510	;turn on character rom
	ora #$02	;point vic to text nybble bank
	sta r6510
.endif
	jsr CLRCHN	;restore default input/output devices


;  initialize editor  GLOBAL  variables

	lda #0
	sta sidreg+24	;turn sound off
	sta graphm	;set display to full text mode
	sta mode	;set display to 40-column vic mode
	sta NDX		;clear keyboard queue
	sta kyndx	;clear function key index
	sta CRSW	;clear <cr> flag
	sta pause	;clear <ctl>-S flag
	sta BLNON	;reset vic cursor status
	sta charen	;reset vic character fetch to rom

	sta vm3		;8563 text area
	lda #$14
	sta vm1		;vic text/character area
	lda #$78
	sta vm2		;vic graphic area
	lda #>vdccol
	sta vm4		;8563 attribute area
	lda ldtb1
	sta ldtb1_sa	;default high byte of vic screen lines

	lda #10
	sta XMAX	;set maximum keyboard buffer size
	sta BLNCT	;reset vic cursor blink count
	sta BLNSW	;start vic cursor blinking
	sta DELAY	;reset delay before a key repeats
	lda #4
	sta KOUNT	;reset delay between key repeats

	jsr taball	;set default tab stops
	sta RPTFLG	;enable key repeats (all keys, .a=$80)
.ifdef target_c128
	ora mmumcr
	sta mmumcr	;enable 40/80 key sense
.endif
	lda #$60
	sta curmod	;reset vdc cursor mode

	lda #$d0
	sta split	;set split screen division 5 lines up from bottom

;	.page
;  initialize editor  LOCAL  variables

	ldx #localabs-localzp-1
	dex
@cint1:
	lda localzp,x
	sta swapbeg,x	;init 40-column vic  mode locals
	lda localabs,x
	sta swapout,x	;init 80-column 8563 mode locals
	dex
	bpl @cint1

	; preserve initial
	lda COLOR
	sta color

	jsr swapzpout
	jsr swapzpin

	ldx #vectse-vectss-1
@cint3:
	lda vectss,x
	sta ctlvec,x	;initialize editor indirect vectors
	dex
	bpl @cint3

	bit init_status	;skip if nmi or user call
	bvs @cint6

.if feature_scnkey=1
	ldx #keyend-keycod-1
@cint4:
	lda keycod,x
	sta decode,x	;initialize keyboard matrix lookup tables
	dex
	bpl @cint4
.endif

.if feature_pfkey=1
	ldx #pkyend-pkytbl-1
@cint5:
	lda pkytbl,x	;initialize programmable key definitions
	sta pkybuf,x
	dex
	bpl @cint5
.endif

	lda #$40	;flag installation
	ora init_status
	sta init_status
@cint6:
	jsr swapper1	;swap in 80-col vars
	jsr taball		;initialize 80-col tab stops
	jsr sreset		;clear 80-col wrap table
	jsr clsr		;clear 80-col text screen

	jsr swapper		;swap in 40-col vars
	jsr sreset		;clear 40-col wrap table
;	jsr clsr		;clear 40-col text screen

.ifdef target_c128
	bit mmumcr	;test 40/80 key & stay in that mode
	bmi @cint10	;...branch if 40 (vic) mode (current mode)
.endif
	jsr swapper	;swap in 80-col mode
@cint10:
	rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
clsr:			;clear the current screen window
.if feature_bgcolor=1
	jsr bgcolor
.endif
	jsr home	;start at top of window
@cl1:
	jsr scrset	;point to a line
	jsr clrln	;clear the line
	cpx scbot	;done if it's the last line in the window
	inx
	bcc @cl1

home:
	ldx sctop	;put the cursor at top left of current window
	stx TBLX	;move to top of window
	stx LSXP	; (for input after home or clear)


stu10:
	ldy sclf	;////// entry from insert/delete line routines
	sty PNTR	;move to left side of window
	sty LSTP

stupt:			;////// entry to set pointers to beginning of current line
	ldx TBLX	;.x now points to beginning of line



scrset:
	lda ldtb2,x	;generate pointers to current screen line
	bit mode	;  (double table values for 80-col mode)
	bpl @sc10
	asl a
@sc10:
	sta PNT		;'pnt' points to screen ram
	lda ldtb1,x
	and #$03
	bit mode
	bpl @sc20
	rol a
	ora vm3
	bcc @sc30	;always
@sc20:
	ora ldtb1_sa
@sc30:
	sta PNT+1		



scolor:
	lda PNT
	sta USER	;'user' points to color ram
	lda PNT+1
	bit mode	;  (different base adr for 80-col)
	bpl @sc1
	and #$07
	ora vm4
	bne @sc2
@sc1:
	and #$03
	ora #>viccol
@sc2:
	sta USER+1
	rts

.if feature_bgcolor=1  ; enable of setting of background color with RVS+CLR
bgcolor:
	lda RVS
	beq bgcolrts
	jsr RVSoff
	lda mode
	bmi bgcolor80
	; flip screen colors: set bacground to cursor color, cursor to background
bgcolor40:
	lda BGCOL0
	and #$0f
	ldx COLOR
	sta COLOR
	sta EXTCOL
	stx BGCOL0
bgcolrts:
	rts
bgcolor80:
	ldy COLOR
	ldx #$1a    ; vdc background color
	jsr vdcin
	and #$0f
	sta COLOR;
	tya 		; prev COLOR
	jsr vdcout
	rts
.endif

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////   E D I T O R   I R Q   R O U T I N E S   \\\\\\\\\\\\\\\\\\

.if feature_irq=1
irq:
	sec
	lda vicreg+25	;is this a vic raster irq?
	and #$01
	beq @irq10		;...branch if not (just rts with .c=1)

	sta vicreg+25	;clear the raster interrupt bit

	lda graphm	;is user controlling vic?
	cmp #$ff
@irq10:
	beq irqrts	;...branch if so (rts with .c=1)

	bit vicreg+17	;assume 'middle' irq (note .c=0 here)
	bmi @irq20		;...branch if not
	and #$40	;make real sure it's a split screen (serial ops may have held irq off)
	bne text	;...branch if somewhere in middle of a split screen

@irq20:
	sec		;flag 'base' irq
	lda graphm	;what will the next frame be?
	beq text	;...branch if all text
	bit graphm
	bvc @irq30		;...branch if not a split screen

	lda split
	sta vicreg+18	;split screen: make next irq occur in 'middle' of frame

;  set up for a graphic frame

@irq30:
	lda r6510
	and #$fd	;point vic to graphic (mcm) nybble bank
	ora #$04	;turn off character rom
	pha

	lda vm2		;point vic to graphic area
	pha

	lda vicreg+17	;turn on bit map mode
	and #$7f	; (keep RC8 clear!)
	ora #$20
	tay

	lda vicreg+22	;turn on/off multicolor mode
	bit graphm
	bmi @irq40
	and #$ef	;off
	.byte $2c

@irq40:
	ora #$10	;on
	tax
	bne doit	;always
;	.page

;  set up for a text frame
text:


	lda #$ff	;make next irq occur at 'base' of this or next frame
	sta vicreg+18

	lda r6510
	ora #$02	;point vic to text nybble bank
	and #$fb	;turn on character rom (if enabled)
	ora charen
	pha

	lda vm1		;point vic to text area
	pha

	lda vicreg+17	;turn off bit map mode
	and #$5f	; (keep RC8 clear!)
	tay

	lda vicreg+22	;turn off multicolor mode
	and #$ef
	tax

	bcs doit	;...branch if at 'base' (not a split screen)

	ldx #7
@te1:
	dex
	bne @te1	;delay for clean switchover
	nop
	nop
	tax

;  install all precomputed values before vic prefetch of next visible line

doit:
	pla
	sta vicreg+24	;set vm
	pla
.ifdef target_c128
	sta r6510	;set charrom + vic nybble bank
.endif
	sty vicreg+17	;set bit map mode
	stx vicreg+22	;set muticolor mode

irqrts:
	bcs @ir10		;kludge for 2MHz mode split screen:
	lda vicreg+48	;...in 2MHz mode, RC8=0 always due to faster code
	and #$01		;...and hence skips keyscan, etc.
	beq @ir10		;...branch if 1MHz mode
	lda graphm
	and #$40
	beq @ir10		;...branch if not split scren
	lda vicreg+17
	bpl @ir10		;...branch if raster still not at bottom
	sec			;ah-ha! this has to be the 'bottom' irq of a split screen
@ir10:
	cli			;allow interruptable keyscan
	bcc @ir20	;done if 'middle' irq
	jsr scnkey	;do general keyboard scan
	jsr blink	;blink vic cursor
	sec			;tell kernal this was the 60hz irq
@ir20:
	rts
.else
irq:
	rts
.endif

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;///////////////   E D I T O R   I N P U T   R O U T I N E S   \\\\\\\\\\\\\\\\

lp2: ;fetch a character from irq key buffer
	ldx kyndx	;check for function key strings first
	beq @lp1  	;...branch if none
.if feature_pfkey=1
	ldy keyidx     	;get index to current character in key string
	lda pkydef,y	;get the character
	dec kyndx	;one less character in string
	inc keyidx	;index to next character
	cli
	clc		;always a good return from keyboard
	rts
.endif
@lp1:
	ldy KEYD	;get a key from irq buffer (.x=0 from 'lp2')
@lp2:
	lda KEYD+1,x	;push down buffer contents
	sta KEYD,x
	inx
	cpx NDX
	bne @lp2

	dec NDX		;one less key in buffer
	tya		;return character in .a
	cli
	clc		;always a good return from keyboard
	rts



loop4:			;fetch characters & display them until <cr>
	jsr print	;print the character in .a
waitky:
	jsr crsron	;enable cursor

@wa1:
	lda NDX	  	;wait here for any buffered keystroke
	ora kyndx	; (or function key)
	beq @wa1

	jsr crsrof	;disable cursor
	jsr lp2		;get the key from irq key buffer

	cmp #cr		;return key?
	bne loop4	;no- buffer to screen until <cr>

	sta CRSW	;set flag to pass characters from screen
	lda #0
	sta QTSW	;clear quote mode
	jsr fndend	;find last non-blank character in line
	stx lintmp	;save last row id ('INDX' = last column)
	jsr fistrt	;find beginning row of this line
	ldy sclf	;assume first character is at left margin

	lda LSXP	;input actually began on this row
	bmi @wa4	;...branch if it's on a wrapped line
	cmp TBLX	;is cursor still on this row?
	bcc @wa4	;...branch if it's below this row

	ldy LSTP	;input actually began in this column
	cmp lintmp	;does input begin & end on same row?
	bne @wa2	;...branch if not
	cpy INDX	;does input begin & end in same column?
	beq @wa3	;...branch if same
@wa2:
	bcs clp2	;...branch if null input
@wa3:
	sta TBLX	;start input from this row
@wa4:
	sty PNTR	;start input from this column
	jmp lop5	;go pass characters



loop5:			;/////  entry for kernal 'basin' routine \\\\\
	tya
	pha		; (save current cursor position)
	txa
	pha
	lda CRSW	;pass characters? (ie: input device = screen)
	beq waitky	;no-  buffer      (ie: input device = keyboard)
	bpl lop5	;yes- if there're any to pass



clp2:
	lda #0		;clear flag- i/o is finished
	sta CRSW
	lda #cr
	ldx #3		;kludge for OPEN4,4 / CMD4 / LIST delemma
	cpx DFLTN
	beq @clp1   ;input is from the screen
	cpx DFLTO
	beq @clp2		;output is to the screen
@clp1:
	jsr print	;force a <cr>
@clp2:
	lda #cr		;pass a return as the last character
	bne clp7	;always
	
;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
lop5:
	jsr  stupt	;set 'pnt' and 'user' to beginning of line
	jsr  get1ch	;get a screen character
	sta  datax
	and  #$3f	;convert chr from screen codes...
	asl  datax
	bit  datax
	bpl  @lo1		;...branch if not alt. character set
	ora  #$80
@lo1:
	bcc  @lo2		;...branch if not RVS fld character
	ldx  QTSW
	bne  @lo3
@lo2:
	bvs  @lo3		;...branch if not shifted character
	ora  #$40
@lo3:
	jsr  qtswc	;...toggle quote mode if quote chr

	ldy TBLX	;check for last non-blank character
	cpy  lintmp
	bcc  @lo4		;...branch if not on last input line
	ldy  PNTR
	cpy  INDX
	bcc  @lo4		;...branch if not on last input column
	ror  CRSW	;make >0 (.c=1) to fake <cr>: this is the last chr
	bmi  @lo5		;always
@lo4:
	jsr  nxtchr	;move 'PNTR' to next character
@lo5:
	cmp  #$de	;a pi ?
	bne  clp7	;no
	lda  #$ff	;translate it to true cbm pi
clp7:
	sta  datax
	pla		; (restore cursor position for 'basin')
	tax
	pla
	tay
	lda  datax	;pass character in .a
	clc		;always a good return from screen or keyboard
	rts

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
qtswc:
	cmp  #quote	;test for quote character
	bne  @qt1		;it's not
	lda  QTSW
	eor  #$01	;toggle quote flag
	sta  QTSW
	lda  #quote
@qt1:
	rts



loop2:			;/////////////   'print' exits here   \\\\\\\\\\\\\\
	lda datax
	sta lstchr	;save in case it's <escape> or <home> for next test
	jsr cursor	;move cursor ahead of output
	lda INSRT
	beq @lo1
	lsr QTSW	;clear quote mode in case quote was hit in insert mode
@lo1:
	pla		;restore all registers
	tay
	pla
	tax
	pla
	clc	      	;good
	rts		;will return to 'loop2'



nxt33:			;various entries from 'print' to output a character
	ora #$40
nxt3:
	ldx RVS		;in RVS mode?
	beq nvs		;no
nc3:
	ora #$80
nvs:
	ldx INSRT	;in insert mode?
	beq @nv1		;no
	dec INSRT	;yes- decrement insert field count
@nv1:
	bit insflg	;in auto insert mode?
	bpl @nv2		;no
	pha		;yes- save the character to insert
	jsr insert	;make room for it
	ldx #0
	stx INSRT	;disallow the other insert mode
	pla
@nv2:
	jsr displc	;display chr & fall thru to 'movchr' (will return to 'loop2')
;	cpy #69
;	bne movchr
;	jsr beep	;ring bell (if enabled) to flag right margin

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; movchr - move to next character position &
;          insert blank line if at end of line
; entry:   .y = column position
; exit:    .c=1 if aborted (scroll disabled)

movchr:
	cpy scrt
	bcc @mc1		;easy if not at end of line
	ldx TBLX
	cpx scbot
	bcc @mc1		;...skip if not last line of screen
	bit scroll
	bmi @mc3		;...abort if scrolling disabled

@mc1:
	jsr stupt	;set up 'pnt' and 'user' vectors
	jsr nxtchr	;move to next char position
	bcc @mc3		;...done if not move to new line
	jsr getbit	;check if on a continued line
	bcs @mc2		;...skip ahead if not
	sec	      	;in case we abort
	bit scroll
	bvs @mc3
	jsr scrdwn	;else insert a blank line
@mc2:
	clc	      	;for clean exit
@mc3:
	rts



; skip to next line (wrap to top if scroll disabled)

nxln:
	ldx TBLX
	cpx scbot	;of the bottom of window ?
	bcc @nx2		;no
	bit scroll	;what if scrolling is disabled?
	bpl @nx1		;branch if scroll is enabled
	lda sctop	;wrap to top
	sta TBLX
	bcs @nx3		;always

@nx1:
	jsr scrup	;scroll it all
	clc		;indicate scroll ok

@nx2:
	inc TBLX

@nx3:
	jmp stupt	;set pointers to beginning of new line

;.end
