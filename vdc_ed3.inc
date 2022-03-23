;	.page
;	.subttl  ed3  irq keyscan & cursor blink routines  (05/09/86)

;/////////////////   K E Y B O A R D     S C A N   \\\\\\\\\\\\\\\\\\\

.if feature_scnkey=1
scnkey:			;scan the keyboard
	lda r6510	;first check is for 'caps lock' key
	and #$40
	eor #$40	;invert sense so '1' means key is down
	lsr a
	lsr a
	sta SHFLAG	;initializes shift key status

	ldy #88		;initialize key counter
	sty SFDX	;assume no keys (88=index to null ($ff) key in table)
	lda #0
	sta colm	;raise all key lines
	sta vicreg+47
	ldx rows	;quick check for any key down in matrix
	cpx #$ff
	bne @sck1		;...branch if anything depressed
	jmp ckit2	;nothing- skip 'way ahead  (restore 'colm' @'ckit2')

@sck1:
	tay		;(.a=0->.y) init key counter
	lda decode
	sta KEYTAB	;assume mode #1 (normal keys)
	lda decode+1
	sta KEYTAB+1

	lda #$ff
	sta vicreg+47
	rol a		;start with 1st column (.a=$fe)


@sck2:
	bit SHFLAG	;msb set means we are scanning extended key lines
	bmi @sck3		;...branch if so
	sta colm
	bpl @sck4
@sck3:
	sta vicreg+47	;raise one column

@sck4:
	ldx #8		;scan 8 rows each column
	pha		;preserve column output configuration

@sck5:
	lda rows	;scan the row
	cmp rows	;debounce the keyboard
	bne @sck5

@sck6:
	lsr a		;look for a key down
	bcs @sck9		;...branch if not this key
	pha		;got one...but preserve remainder

	lda (KEYTAB),y	;fetch the character code for this key

	cmp #$08	;check for modifier keys................$01 = shift
	beq @sck7		;...branch if 'alt' key			    $02 = C=
	cmp #$05		;                                   $04 = control
	bcs @sck8		;...branch if not a modifier key	$08 = alt
	cmp #$03		;                                   $10 = caps lock
	beq @sck8		;...branch if not a modifier key
@sck7:
	ora SHFLAG
	sta SHFLAG	;save modifier (merge in into flag byte)
	.byte $2c

@sck8:
	sty SFDX	;save key number
	pla		;recall the rest of the row
@sck9:
	iny		;index to next key
	dex		;index to next row
	bne @sck6		;...branch if still more keys in this row

	cpy #89
	bcs @sck10		;...branch if finished all keys

	pla		;recall column configuration
	sec
	rol a		;rotate scan to next column
	bcs @sck2		;...branch if still more columns
	sta colm	;(.a=$ff) drop all lines driving old matrix
	rol SHFLAG
	sec
	ror SHFLAG	;flag we are now scanning extended matrix
	rol a		;(.a=$fe)
	bne @sck2		;always


@sck10:
	asl SHFLAG	;remove temporary flag bit
	lsr SHFLAG
	pla		;clean up- all done.  pass key number in .a and...
	lda SFDX  	;...fall into 'keylog' to determine how to decode key

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	jmp (keyvec)	;'keylog' indirect

keylog:			;evaluate various shift keys & determine lookup table
	cmp #87
	bne @kl10		;special test for <scroll> key
	bit locks
	bvs @kl99		;...branch if disabled
	lda LSTSHF
	bne @kl99		;...branch if too soon
	lda #13		;<ctrl>-S
	eor pause
	sta pause	;toggle pause flag
	bvc @kl20		;setup slight delay

@kl10:
	lda SHFLAG
	beq repeat	;...branch if none depressed, 'KEYTAB' already set up
	cmp #$10
	beq @kl40		;...branch if <caps-lock> only
	cmp #$08
	beq @kl50		;...branch if <alt> only
	and #$07

	cmp #3		;<commodore><shift> combination?
	bne @kl30		;...branch if not
	lda locks	;got it, but is it locked out?
	bmi repeat	;...branch if locked out
	lda LSTSHF	;has there been enough delay since last time?
	bne repeat	;...branch if more delay needed

	bit mode
	bpl @kl15		;...branch if 40-col (vic) mode
	lda COLOR
	eor #$80	;toggle case by toggling 8563 attribute ALT bit
	sta COLOR	; (note: does not affect characters already displayed-
	jmp @kl20		;        it does allow all 512 chrs to appear simultaneously.)

@kl15:
	lda vm1		;toggle case by redirecting vic character base register
	eor #$02	; VIC(cb11)
	sta vm1		;change will occur at next display frame

@kl20:
	lda #%00001000	;provide a delay between toggles
	sta LSTSHF	; (reset by 'ckit2' shifting 'LSTSHF' right)
	bne repeat	;always



@kl30:
	asl a		;make flag value a table pointer
	cmp #8		;<control> key?		(overrides all other modes)
	bcc @kl50		;...branch if not down	(.a points to correct matrix)

	lda #6		;set table pointer to <ctrl> matrix
	ldx SFDX	;check for <ctrl>-S combination (pause output)
	cpx #13
	bne @kl50	;...branch if not 'S'
	bit locks
	bvs @kl50	;...branch if locked out
	stx pause	;set flag for pause
@kl99:
	rts

@kl40:
	lda #10		;set table pointer to <caps-lock> matrix

@kl50:
	tax		;.a = table pointer
	lda decode,x
	sta KEYTAB	;setup vector to that table
	lda decode+1,x
	sta KEYTAB+1	;fall thru to 'repeat' handler & 'ckit2'

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
repeat:			;handler for key repeats
	ldy SFDX  	;get key index
	lda (KEYTAB),y  ;lookup key value from proper table
	tax		;save key value for 'ckit2' in .x

	cpy LSTX	;is the index the same as found during last key scan?
	beq @rp20	;...branch if it is
	ldy #$10
	sty DELAY	;reset the delay before a key repeats
	bne ckit2	;always


@rp20:
	and #$7f	;mask off shift bit
	bit RPTFLG	;are key repeats enabled?
	bmi @rp30		;...branch if all keys repeat
	bvs scnrts	;...branch if no  keys repeat
	cmp #$7f
	beq ckit2	;...branch if nothing to repeat (no real key down)

	cmp #$14	;repeat only cursor keys, space bar, and delete key
	beq @rp30		;...branch if <inst/del>
	cmp #space
	beq @rp30		;...branch if <space>
	cmp #$1d
	beq @rp30		;...branch if <crsr l/r>
	cmp #$11
	bne scnrts	;...branch if not <crsr u/d>

@rp30:
	ldy DELAY	;repeat this key
	beq @rp40		;...branch if key has been down long enough to repeat
	dec DELAY	;else keep counting down
	bne scnrts

@rp40:
	dec KOUNT
	bne scnrts	;...branch if between key repeats
	ldy #4
	sty KOUNT	;reset between_key_repeats counter
	ldy NDX
	dey		;got a repeating key- is there room for it in buffer?
	bpl scnrts	;...branch if no room (ignore it)
			;else fall into 'ckit2' & put key (in .x) into buffer

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
ckit2:			;key is in .x
	lsr LSTSHF	;do <cbm><shift> delay  (if any)

	ldy SFDX	;get index of current key
	sty LSTX	;update last_key_found value
	cpx #$ff	;.x has the key code (from 'repeat')
	beq scnrts	;...branch if it's null (nothing down)

	lda #0
	sta pause	;any key clears the <ctrl>-S pause flag

	txa		;decoded key
	ldx SHFLAG	;status of special keys
	jmp (keychk)	;.a=character, .y=keycode, .x=shift status
.else
scnkey:
repeat:
	rts
.endif

keyput:
	ldx #9		;check for function keys, <shift><run>, or <help>

@kp1:
	cmp funtab,x	;compare with function key codes
	beq dopfky	;...branch if it is a function key
	dex
	bpl @kp1

	ldx NDX		;finally put key into the damn buffer!
	cpx XMAX
	bcs scnrts	;...branch if buffer is full (ignore key)
	sta KEYD,x	;put it in
	inx		;one more key in buffer
	stx NDX		;update key queue count

scnrts:
	lda #$7f
	sta colm	;restore scan to last column (run/stop)
	rts

;	.page

dopfky:
.if feature_pfkey=1
	jmp dopfky_patch	;-05 FIX (FAB)

;	lda pkybuf,x    ;find length of function key string
	sta kyndx
	lda #0    	;find index to start of string

@do1:
	dex
	bmi @do2
	clc
	adc pkybuf,x
	bcc @do1		;always

@do2:
	sta keyidx
.endif
	rts




funtab:
	.byte   $85,$89,$86,$8a		;f1-f4
	.byte   $87,$8b,$88,$8c		;f5-f8
	.byte	$83,$84			;<shift><run>, <help>

;	.page \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

blink:			;////////// vic cursor blinker \\\\\\\\\\\\\
	bit mode
	bmi @bl2		;...branch if 8563 mode (hardware cursor)
	lda BLNSW
	bne @bl2		;...branch if cursor not enabled (rts)
	dec BLNCT
	bne @bl2		;...branch if not time to blink	(rts)
	lda BLNON
	and #$c0
	cmp #$c0
	beq @bl2		;...branch if solid cursor & 'GDBLN' is correct

	lda #20		;reset blink counters
	sta BLNCT
	ldy PNTR	;get current cursor position
	ldx GDCOL	    ;get correct COLOR
	lda (PNT),y	;get screen character at cursor
	bit BLNON
	bmi @bl1		;...branch if cursor was on

	sta GDBLN	;cursor was off, save good character
	jsr scolor
	lda (USER),y	;get screen COLOR at cursor
	sta GDCOL	;save COLOR
	ldx COLOR	;cursor always appears in current fgnd COLOR
	lda GDBLN	;character under cursor

@bl1:
	eor #$80	;toggle character field bit to 'blink' cursor
	jsr displ	;display this character & COLOR & rts
	lda BLNON
	eor #$80
	sta BLNON	;toggle cursor
@bl2:
	rts


;.end
