; VDOS - C64 floppy speeder and disk utility
; 1986, Edward Carroll
; Public domain.

; Disassembled and commented (quick and dirty) by 1570
; xa65 format

; Usage:
; LOAD"!*PROGRAM",8,1 - autostart VDOS, fastload PROGRAM
; LOAD"!",8 RUN - save autostarting VDOS to (new) disk
; VERIFY - send commands, read floppy status
; VERIFY"$" - display directory
; VDOS uses memory at CB00 and therefore limits length
; of programs loaded to basic start to about 195 blocks.

	.word $031a
	* = $031a

; BASIC header SYS 2169 ($0879)
; In case this gets loaded to BASIC start (,8)
; Will overwrite IOPEN, ICLOSE, ICHKIN, ICHKOUT,
; ICLRCH, IBASIN vectors otherwise
l31a 	.byt $0b,$08,$c2
	.byt $07,$9e,$32
	.byt $31,$36,$39
	.byt $00,$00,$00

; IBASOUT/CHROUT vector ($0326)
	.word autostart
; ISTOP ($0328)
	.word $f6ed
; IGETIN ($032A)
	.word $f13e
; ICLALL ($032C)
	.word $f32f
; USRCMD ($032E)
	.word $fe66
; ILOAD ($0330)
iload:	.word $f4a5
; ISAVE ($0332)
	.word $f5ed

autostart:
	jsr $fd15	; restore kernal vectors
	sei
	lda #$30
	sta $01
	ldy #$00
l33e	lda $03e0,y
	sta $da80,y
	lda $04e0,y
	sta $db80,y
	lda $05e0,y
	sta $dc80,y
	lda $06e0,y
	sta $dd80,y
	iny
	bne l33e
l359	jsr ldace	; install helpers, display message
	jsr $a533	; rechain basic lines
	lda $22
	clc
	adc #$02
	sta $2d
	lda $23
	adc #$00
	sta $2e
	jsr $a660	; clear screen
	ldy $b7	; number of characters in filename
	dey
	bne l377
l374	jmp ($a002)	; basic warm start
l377	dey
	sty $b7	; number of characters in filename
	lda $bb
	clc
	adc #$02
	sta $bb
	bcc l385
l383	inc $bc
l385	lda #$01
	sta $b9 ; current sa
	lda #$a4
	pha
	lda #$7f
	pha
	jmp $e16f	; load (will jump through iload)

; Code called by BASIC stub.
; Just copies everything to standard location and saves.
; Located at $0879.
l392	lda #$61
	sta $b9		; Secondary address ($61 = SAVE)
	lda #$01
	ldx #<filename
	ldy #>filename
	jsr $ffbd	; Set Filename
	ldy #$00
l3a1	lda $0801,y
	sta $031a,y
	lda $0901,y
	sta $041a,y
	lda $0a01,y
	sta $051a,y
	lda $0b01,y
	sta $061a,y
	lda $0bc5,y
	sta $06de,y
	iny
	bne l3a1
l3c2	jsr $f3d5	; Send Secondary Address
	lda #<l31a
	sta $c1
	lda #>l31a
	sta $c2		; Set start address
	lda #<(lastbyte+1)
	sta $ae
	lda #>(lastbyte+1)
	sta $af		; Set end address
	jsr $f60b	; Save (without printing "SAVING")
	lda #$01
	sta $b7		; Number of characters in filename
	jmp autostart

filename:
	.byt $21

	* = $da80
lda80	jsr lda89	; swap cb00.. and db00..
	jsr ldaf2	; move helper to 02e1
	jmp lcd6a	; display message, install load vector, exit

; swap cb00.. and db00..
lda89	php
	pha
	stx ldafe
	sty ldaff
	lda #$db
	sta ldaa7
	sta ldaae
	lda #$cb
	sta ldaab
	sta ldab2
	ldx #$05
	ldy #$00
ldaa5	ldaa7 = * + 2
	lda $db00,y
	pha
	ldaab = * + 2
	lda $cb00,y
	ldaae = * + 2
	sta $db00,y
	pla
	ldab2 = * + 2
	sta $cb00,y
	iny
	bne ldaa5
ldab6	inc ldaa7
	inc ldaae
	inc ldaab
	inc ldab2
	dex
	bne ldaa5
ldac5	ldx ldafe
	ldy ldaff
	pla
	plp
ldace = * + 1
	rts

	* = $02e1
l2e1	clc
	.byt $24	; bit $xx
; iload vector
l2e3	sec
	sei
	pha
	lda $01
	sta $92
	lda #$30
	sta $01
	bcc l2f3
	jmp ldaec	; swap cb00/db00, load/verify
l2f3	jmp lda80	; install helper, display message
l2f6	jsr lda89	; swap cb00.. and db00..
	lda $92
	sta $01
	cli
	rts

	* = $daec
ldaec	jsr lda89	; swap cb00.. and db00..
	jmp lcc05	; load/verify

; move helper to 02e1
ldaf2	ldy #$1e
ldaf4	lda ldace,y
	sta $02e1,y
	dey
	bpl ldaf4
ldafd	rts


ldafe	.byt $00
ldaff	.byt $00

; db00
	* = $cb00
lcb00	rts
lcb01	ora $fd,x
lcb03	bit $c5
	bvc lcb03
lcb07	jsr lcd8f
	jsr lcd96
	jsr lcb48
	jsr lcb48
lcb13	jsr $aad7	; output cr/lf
	jsr $ab3f	; output format character
	jsr lcb48
	jsr lcb48
	jsr lcb48
	tax
	jsr lcb48
	jsr $bdcd	; output number in FAC
	jsr $ab3f	; output format character
lcb2c	jsr lcb48
	beq lcb13
lcb31	ldy $d3
	cpy #$19
	bne lcb42
lcb37	cmp #$20
	beq lcb42
lcb3b	pha
	lda #$3a
	jsr $ffd2	; chrout
	pla
lcb42	jsr $ffd2	; chrout
	jmp lcb2c
lcb48	jsr $ffa5	; handshake serial byte in
	bit $90
	bvs lcb68
lcb4f	bit $91
	bpl lcb65
lcb53	bit $c5
	bvs lcb63
lcb57	bit $c5
	bvc lcb57
lcb5b	bit $c5
	bvs lcb5b
lcb5f	bit $c5
	bvc lcb5f
lcb63	tay
	rts

lcb65	jsr $aad7	; output cr/lf
lcb68	jsr $ffab	; untalk
	jsr $f642	; save file to serial bus

; read error channel
lcb6e	jsr $aad7	; output cr/lf
	jsr $ab3f	; output format character
	lda $ba	; device number
	jsr $ffb4	; talk
	lda #$6f
	jsr $ff96	; send sa after talk
lcb7e	jsr $ffa5	; handhake serial byte in
	jsr $ffd2	; chrout
	cmp #$0d
	bne lcb7e
lcb88	jsr $ffab	; untalk
	lda #$00
	sta $c6	; number of chars in keyboard buffer
lcb8f	ldx #$fb
	txs
	lda #>$a473
	ldy #<$a473	; break entry
	jmp lcd24	; return to vector in a/y

; transfer routine
lcb99	ldy #$00
lcb9b	iny
	bne lcb9b	; delay
lcb9e	ldx $ac
	lda $d020
lcba3	inc $d020
	bit $dd00	; drive start condition
	bmi lcba3
lcbab	stx $dd00
	sta $d020
lcbb1	lda $d012
	eor #$02
	and #$06
	beq lcbb1	; badline check
lcbba	lda $ad
	sta $dd00	; host start signal
	pha
	pla
	pha
	pla
	nop
	lda $dd00
	lsr
	lsr
	nop
	ora $dd00
	and #$f0
	sta lcbe3
	lda $dd00
	lsr
	lsr
	nop
	ora $dd00
	stx $dd00
	lsr
	lsr
	lsr
	lsr
	lcbe3 = * + 1
	ora #$f0
	sta $cf00,y
	iny
	bne lcbb1
lcbea	lda $ad
	sta $dd00
	rts
lcbf0	lda $cf02
	ldy $cf03
	ldx $ab
	bne lcbfe
lcbfa	lda $c3
	ldy $c4
lcbfe	sta $ae
	sty $af
	jmp lcd38

; load/verify
lcc05	lda #$37
	sta $01
	cli
	pla
	sta $93	; load/verify
	lda $b9 ; current sa
	sta $ab
	lda $ba	; device number
	cmp #$01
	bne lcc1b
lcc17	lda #$08
	sta $ba	; device number
lcc1b	cmp #$04
	bcc lcc2e	; use kernal load
lcc1f	ldy #$00
	lda ($bb),y	; file name
	cmp #$24	; Directory?
	bne lcc35
lcc27	lda $93	; load/verify
	beq lcc2e	; use kernal load
lcc2b	jmp lcb03
lcc2e	ldy #<$f4a6
	lda #>$f4a6	; kernal load ram
	jmp lcd24	; return to vector in a/y
lcc35	lda $93	; load/verify
	beq lcc43
lcc39	lda $b7	; number of characters in filename
	bne lcc40
lcc3d	jmp lcb6e	; read error channel
lcc40	jmp lcd48	; send command
lcc43	lda $b7	; number of characters in filename
	bne lcc4e
lcc47	ldy #<$f70f
	lda #>$f70f	; missing filename
	jmp lcd24	; return to vector in a/y
lcc4e	jsr $f5af
	jsr lcd8f
	jsr lcd96
	jsr $ffa5	; handhake serial byte in
	lda $90
	lsr
	lsr
	bcc lcc67
lcc60	ldy #<$f703
	lda #>$f703	; file not found
	jmp lcd24	; return to vector in a/y
lcc67	jsr $f5d2
	ldy #$00
	sty $d015
lcc6f	jsr lcd5d	; send M-
	lda #$57	; W
	jsr $ffa8	; handshake serial byte out
	tya	; #0
	jsr $ffa8	; handshake serial byte out
	lda #$06
	jsr $ffa8	; handshake serial byte out
	lda #$1e
	jsr $ffa8	; handshake serial byte out
	ldx #$1e	; length of drive code
lcc87	lda drivecode,y
	jsr $ffa8	; handshake serial byte out
	iny
	dex
	bne lcc87
lcc91	jsr $ffae	; unlisten
	cpy #$9a
	bcc lcc6f
lcc98	jsr lcd5d	; send M-
	lda #$45	; E
	jsr $ffa8	; handshake serial byte out
	lda #$00
	jsr $ffa8	; handshake serial byte out
	lda #$06
	jsr $ffa8	; handshake serial byte out
	jsr $ffae	; unlisten
	sei
	lda $dd00
	and #$03
	ora #$04
	sta $ad
	ora #$10
	sta $ac
	jsr lcb99	; transfer routine
	jsr lcbf0
	ldx #$04
	bne lccce
lccc5	jsr lcb99	; transfer routine
	lda #$30
	sta $01
	ldx #$02
lccce	ldy #$00
	lda $cf00
	beq lcce9
lccd5	bmi lcd08
lccd7	lda $cf00,x
	sta ($ae),y
	jsr lcd32
	inx
	bne lccd7
lcce2	lda #$37
	sta $01
	jmp lccc5

lcce9	dex
lccea	lda $cf01,x
	sta ($ae),y
	jsr lcd32
	inx
	cpx $cf01
	bcc lccea
lccf8	lda #$37
	sta $01
	lda $af
	cmp #$d0
	bcc lcd06
lcd02	sbc #$10
	sta $af
lcd06	clc
	.byt $24	; BIT #$xx
lcd08	sec
	php
	lda $ac
	ora #$cc
	sta $dd00
	jsr lcda0
	lda #$49
	jsr $ffa8	; handshake serial byte out
	jsr $ffae	; unlisten
	jsr lcb00
	plp
	ldy #<$f5a9
	lda #>$f5a9	; print SEARCHING
; return to vector in a/y
lcd24	pha
	tya
	pha
lcd27	sei
	lda #$30
	sta $01
	jsr ldaf2	; move helper to 02e1
	jmp l2f6	; swap cb00/db00, exit

lcd32	inc $ae
	bne lcd47
lcd36	inc $af
lcd38	lda $af
	cmp #$cb
	bcc lcd47
lcd3e	cmp #$00
	bcs lcd47
lcd42	clc
	adc #$10
	sta $af
lcd47	rts

; send drive command
lcd48	jsr lcda0
	ldy #$00
lcd4d	lda ($bb),y
	jsr $ffa8	; handshake serial byte out
	iny
	cpy $b7	; number of characters in filename
	bcc lcd4d
lcd57	jsr $ffae	; unlisten
	jmp lcb8f

lcd5d	jsr lcda0
	lda #$4d	; M
	jsr $ffa8	; handshake serial byte out
	lda #$2d	; -
	jmp $ffa8	; handshake serial byte out

; display message, install load vector, exit
lcd6a	pla
	lda #$37
	sta $01
	sta $92
	lda #$00
	sta $d021
	lda #$06
	sta $d020
	lda #<lcdac
	ldy #>lcdac
	jsr $ab1e	; output string
	lda #<l2e3
	ldy #>l2e3
	sta iload
	sty iload+1
	jmp lcd27	; install 02xx helper, swap cb00/db00, exit

lcd8f	lda #$60
	sta $b9 ; current sa
	jsr $f3d5	; Send Secondary Address
lcd96	lda $ba	; device number
	jsr $ffb4	; Command Serial Bus TALK
	lda $b9 ; current sa
	jmp $ff96	; Send SA After Talk
lcda0	lda #$6f
	pha
	lda $ba	; device number
	jsr $ffb1	; Command Serial Bus LISTEN
	pla
	jmp $ff93	; Send SA After Listen

; Message
lcdac	.byt $93,$11,$9e
	.byt $20,$54,$55
	.byt $52,$42,$4f
	.byt $4c,$4f,$41
	.byt $44,$20,$2b
	.byt $20,$56,$44
	.byt $4f,$53,$20
	.byt $37,$33,$37
	.byt $20,$2d,$99
	.byt $20,$42,$59
	.byt $20,$45,$44
	.byt $44,$59,$20
	.byt $43,$41,$52
	.byt $52,$4f,$4c
	.byt $4c
drivecode = * + 1
	.byt $0d

; Drive code (in drive at $0600)
	* = $738
	ldy #$00
l73a	tya
	and #$0f
	tax
	lda $068a,x
	sta $0400,y
	tya
	lsr
	lsr
	lsr
	lsr
	tax
	lda $068a,x
	sta $0500,y
	iny
	bne l73a
l753	lda $18
	sta $06
	lda $19
	sta $07
l75b	lda #$b0
	sta $00
l75f	lda $00
	bmi l75f
l763	lda #$80
	sta $00
l767	lda $00
	bmi l767
l76b	sei
	cmp #$01
	beq l775
l770	lda #$ff
	sta $0300
l775	lda #$02
	sta $1800
	asl
l77b	bit $1800
	beq l77b
l780	ldx $0300,y
l783	bit $1800
	bne l783
l788	lda $0500,x
	sta $1800
	asl
	and #$0f
	nop
	sta $1800
	lda $0400,x
	nop
	sta $1800
	asl
	and #$0f
	nop
	sta $1800
	lda #$04
	iny
	nop
	sta $1800
	bne l780
l7ac	cli
	lda $0301
	sta $07
	lda $0300
	beq l7c1
l7b7	bmi l7c1
l7b9	cmp $06
	sta $06
	beq l763
l7bf	bne l75b
l7c1	rts
	.byt $0f,$07,$0d
	.byt $05,$0b,$03
	.byt $09,$01,$0e
	.byt $06,$0c,$04
	.byt $0a,$02
lastbyte:
	.byt $08
