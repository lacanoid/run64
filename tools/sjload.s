.feature labels_without_colons

feature_colors = 2

; SJLOAD - C64 floppy speeder and disk utility
; based on VDOS by Edward Carroll 1986
; modified for Jiffy compatibility by 1570 in 2008

; todo
;  move core routines above $e000 instead of $cb00
;  much cleanup

; xa65 assembler format

; Usage:
; LOAD"!*PROGRAM",8,1 - autostart VDOS, fastload PROGRAM
; LOAD"!",8 RUN - save autostarting VDOS to (new) disk
; VERIFY - send commands, read floppy status
; VERIFY"$" - display directory

; VDOS uses memory at CB00 and therefore limits length
; of programs loaded to basic start to about 195 blocks.

	.word $031a
	.org  $031a

; BASIC header SYS 2169 ($0879)
; In case this gets loaded to BASIC start (,8)
; Will overwrite IOPEN, ICLOSE, ICHKIN, ICHKOUT,
; ICLRCH, IBASIN vectors otherwise
firstbyte:
 	.byt $0b,$08,$d8
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

; $DD00 bits
; 0..1 VIC bank
; 2 RS-232 TXD Ausgang, User PA 2
; 3..5 IEC OUT. 0=High/Inactive, 1=Low/Active.
; 3 ATN OUT
; 4 CLOCK OUT
; 5 DATA OUT
; 6..7 IEC IN. 0=Low/Active, 1=High/Inactive.
; 6 CLOCK IN
; 7 DATA IN 

autostart:
	jsr $fd15	; restore kernal vectors
	sei
	lda #$30
	sta $01
l33c	ldy #$00
l33e	lda da80code,y
l341	sta $da80,y
	iny
	bne l33e
	inc l33e+2
	inc l341+2
	lda l341+2
	cmp #$e0
	bne l33c
	lda #$00
	sta $0800	; remove garbage in $0800 confusing RUN
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
	bne autoload	; b.i. more than 1 character in filename
l374	jmp ($a002)	; basic warm start

autoload:
	dey
	sty $b7	; number of characters in filename
	lda $bb
	clc
	adc #$02
	sta $bb	; advance filename pointer by two chars ("!*")
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
	sta firstbyte+$0000,y
	lda $0901,y
	sta firstbyte+$0100,y
	lda $0a01,y
	sta firstbyte+$0200,y
	lda $0b01,y
	sta firstbyte+$0300,y
	lda $0c01,y
	sta firstbyte+$0400,y
	iny
	bne l3a1
l3c2	jsr $f3d5	; Send Secondary Address
	lda #<firstbyte
	sta $c1
	lda #>firstbyte
	sta $c2		; Set start address
	lda #<$07ff	; TODO use proper end address
	sta $ae
	lda #>$07ff
	sta $af		; Set end address
	jsr $f60b	; Save (without printing "SAVING")
	lda #$01
	sta $b7		; Number of characters in filename
	jmp autostart

filename:
da80code = * + 1
	.byt $21

	.org $da80
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
ldaa5	
ldaa7 = * + 2
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

; this code portion is relocatable and called both at $dace and $02e1
	.org $02e1
	clc
	.byt $24	; bit $xx
; iload vector
vload:	sec
	sei
	pha
	lda $01
	sta $92
	lda #$30
	sta $01
	bcc vlnm
	jmp ldaec	; swap cb00/db00, load/verify
vlnm:	jmp lda80	; install helper, display message
l2f6	jsr lda89	; swap cb00.. and db00..
	lda $92
	sta $01
	cli
	rts

	.org $daec
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
	.org $cb00
lcb00	rts
lcb01	ora $fd,x
listDir:
	bit $c5
	bvc listDir
	lda #$60
	sta $b9 ; current sa
	jsr $f3d5	; Send Secondary Address
lcd96	lda $ba	; device number
	jsr $ffb4	; Command Serial Bus TALK
	lda $b9 ; current sa
	jsr $ff96	; Send SA After Talk
;	jsr lcd96 (was doubled in VDOS?)
	jsr ldgc
	jsr ldgc
lcb13	lda #$0d
	jsr $e10c	; Output character
	lda #$0a
	jsr $e10c	; Output character
	lda #$20
	jsr $e10c	; Output character
	jsr ldgc
	jsr ldgc
	jsr ldgc
	tax
	jsr ldgc
	jsr $bdcd	; output number in FAC
	lda #$20
	jsr $e10c	; Output character
lcb2c	jsr ldgc
	beq lcb13
lcb31	ldy $d3
	cpy #$19
	bne lcb42
lcb37	cmp #$20
	beq lcb42
lcb3b	pha
	lda #$3a	; ":"
	jsr $ffd2	; chrout
	pla
lcb42	jsr $ffd2	; chrout
	jmp lcb2c

; get serial byte (with error handling)
ldgc:	jsr $ffa5
	bit $90
	bvs lcb68
lcb4f	bit $91
	bpl readError
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

; read error channel
readError:
	jsr $aad7	; output cr/lf
lcb68	jsr $ffab	; untalk
	jsr $f642	; in save (send LISTEN?)
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
vExit:	ldx #$fb
	txs
	lda #>$a473
	ldy #<$a473	; Restart BASIC ($a474)
	jmp returnOut

; send drive command
sendCmd:
	lda #$6f
	pha
	lda $ba	; device number
	jsr $ffb1	; Command Serial Bus LISTEN
	pla
	jsr $ff93	; Send SA After Listen
	ldy #$00
lcd4d	lda ($bb),y
	jsr $ffa8	; handshake serial byte out
	iny
	cpy $b7	; number of characters in filename
	bcc lcd4d
	jsr $ffae	; unlisten
	jmp vExit

; load/verify
lcc05	lda #$37
	sta $01
	cli
	pla
load	sta $93		; load/verify flag
	lda #$00
	sta $90		; iec status
	lda $ba		; device number
	bne cdn
	jmp $f713
cdn	cmp #$03
	bne lload
	bcs lload
	jmp $f4af

; actual LOAD routine
lload	ldx $ba	; device number
	cpx #$01	; device 1 (default)? Override with 8.
	bne vnstd
	ldx #$08
	stx $ba	; device number
vnstd:	lda $93	; load/verify
	beq lnv	; b.i. load
	lda $b7	; number of characters in filename
	bne vsc
	jmp readError
vsc:	ldy #$00
	lda ($bb),y	; file name
	cmp #$24
	bne sendCmd
	jmp listDir
lnv:	ldx $b7		; length of filename
	bne lfnok
	lda #>$f712
	ldy #<$f712
	jmp returnOut	; illegal device number ($f713)
lfnok	ldx $b9		; secondary address
	jsr $f5af	; searching for filename
	sei
	lda $d011
	and #$ef
	sta $d011	; disable screen
ld1	lda $d011	; wait for next screen
	bpl ld1
ld2	lda $d011
	bmi ld2
	lda #$60	; sa for load
	sta $b9		; secondary address
	jsr $f3d5	; open file/open secondary address
	sei		; $f3d5 does cli
	lda $ba		; device number
	jsr ltalk	; talk
	lda $b9		; secondary address
	jsr lsendsa	; send sa
	jsr lgiecin	; iecin (get load address lo)
	sta $ae		; load address lo
	lda $90		; iec status
	lsr
	lsr
	bcc liecok
	lda #>$f703
	ldy #<$f703
	jmp returnOut	; file not found ($f704)
liecok	jsr lgiecin	; iecin (get load address hi)
	sta $af		; load address hi
	inc $b9		; secondary address 61 = JD load
	jsr luntalk	; untalk
	lda $ba		; device number
	jsr ltalk	; talk
	lda $b9		; secondary address
	jsr lsendsa	; send sa
	dec $b9		; secondary address
	cpx #$00	; original secondary address
	bne lloadabs2	; branch if load absolute
	lda $c3		; basic start lo
	sta $ae		; load address lo
	lda $c4		; basic start hi
	sta $af		; load address hi
lloadabs2	jsr $f5d2	; loading message
	ldy #$00
	ldx #$00
ljlw:	dex
	bne ljlw

	lda $d020
	sta $0110

lloadinnerloop:
	lda $0110
	sta $d020

	lda #$03
	sta $dd00	; IEC lines inactive/high
lwch1	bit $dd00
	bvc lwch1	; wait until 1541 sets clock inactive/high
	bmi lprocessdrivesignal	; branch if data inactive/high (some signal to process)
ltransferblock:
	bit $dd00
	bpl ltransferblock	; wait until 1541 sets data inactive/high
ltransferbyte:
.if feature_colors=2
	nop
	inc $d020 ; 6
.else
	nop		; timing critical section
	nop     ; 2
	nop
	nop
.endif

	lda #$03
	ldx #$23
	stx $dd00	; data=active,clock=inactive,ATN=inactive
	bit $dd00
	bvc lloadinnerloop	; branch if 1541 sets clock active (needs to load next block)
	nop
	sta $dd00	; set data inactive
	lda $dd00	; read bits 1/0
	nop
	lsr
	lsr
	eor $dd00	; read bits 3/2
	bit $00		; burn cycles
	lsr
	lsr
	eor $dd00	; read bits 5/4
	bit $00		; burn cycles
	lsr
	lsr
	eor $dd00	; read bits 7/6
	eor #$03
	sta ($ae),y	; store byte
	inc $ae		; load address lo
	bne ltransferbyte
	inc $af		; load address hi
	jmp ltransferbyte
lprocessdrivesignal:
	ldx #$64
lwok1	bit $dd00
	bvc lend2	; 1541 sets clock active/low: everything ok
	dex
	bne lwok1	; wait for ok signal or timeout
	lda #$42	; end, error
	.byt $2c
lend2	lda #$40	; end, okay
	jsr $fe1c	; set iec status ($90)
	jsr luntalk	; UNTALK
	jsr $f642	; In Save (close file)
	bcc lend3
	lda #>$f703
	ldy #<$f703
	jmp returnOut	; file not found ($f704)
lend3	lda #>$f5a8
	ldy #<$f5a8
	jmp returnOut	; ok ($f509)



; TALK
ltalk	ora #$40
lsendb	sta $95	; byte to send
	jsr $ee97	; Set Data inactive
	cmp #$3f
	bne lca1
	jsr $ee85	; Set Clock inactive
lca1	lda $dd00
	ora #$08
	sta $dd00	; Set ATN active
; send IEC byte
lwiecs	jsr $ee8e	; Set Clock active
	jsr $ee97	; Set Data inactive
	jsr $eeb3	; Delay 1 ms
	jsr $eea9	; Data => Carry, Clock => M
	bcc lcont1	; branch if data active
	lda #>$edac
	ldy #<$edac
	jmp returnOut	; device not found ($edad)
lcont1	jsr $ee85	; Set Clock inactive
lcont4	jsr $eea9	; Data => Carry, Clock => M
	bcc lcont4	; Wait until data inactive
	jsr $ee8e	; Set Clock active
	txa
	pha		; save X
	ldx #$08	; 8 bits to send
lsendbits	nop
	nop
	nop
	bit $dd00
	bmi lcont5
	pla
	tax		; restore X
	lda #>$edaf
	ldy #<$edaf
	jmp returnOut	; timeout ($edb0)
lcont5	jsr $ee97	; Set Data inactive
	ror $95	; byte to send
	bcs lci1
	jsr $eea0	; Set Data active
lci1	jsr $ee85	; Set Clock inactive
	lda $dd00
	and #$df
	ora #$10
; send two bits
	sta $dd00
	and #$08
	beq ltwobitssent
	lda $95	; byte to send
	ror
	ror
	cpx #$02
	bne ltwobitssent
	ldx #$1e
lwack1	bit $dd00
	bpl lwack2
	dex
	bne lwack1
	beq lcont6
lwack2	bit $dd00
	bpl lwack2
	; when we are here JD is present in floppy
lcont6	ldx #$02
ltwobitssent:
	dex		; other dex is above
	bne lsendbits	; branch if still bits to send
	ldx #$56
lcont7:	dex
	beq ltbtimeout
	lda $dd00
	bmi lcont7	; wait until data active
ltbok:	pla
	tax		; restore X
	rts
ltbtimeout:
	pla
	tax		; restore X
	lda #>$edaf
	ldy #<$edaf
	jmp returnOut	; Write timeout ($edb0)

; SEND SECONDARY ADDRESS
lsendsa	sta $95	; byte to send
	jsr lwiecs	; send IEC byte
	lda #$23	; Data active, ATN/clock inactive
	sta $dd00
lwca1	bit $dd00
	bvs lwca1	; Wait until clock active
	rts

; UNTALK
luntalk	lda $dd00
	ora #$08
	sta $dd00	; Set ATN active
	jsr $ee8e	; Set Clock active
	lda #$5f	; UNTALK command
	jsr lsendb	; send byte
	jsr $edbe	; Clear ATN
	txa
	ldx #$0a
ll2	dex
	bne ll2
	tax
	jsr $ee85	; Set Clock inactive
	jmp $ee97	; Set Data inactive


; IECIN (jumped to from EE13)
lgiecin:
ll3	lda $dd00
	cmp #$40
	bcc ll3
.if feature_colors=1
	inc $d020
.else
	nop
	nop
	nop
.endif
	nop
	nop
	nop
	nop
	nop
	lda #$03
	nop
	nop
	sta $dd00
	nop
	nop
	nop
.if feature_colors=1
	dec $d020
.else
	nop
	nop
	nop
.endif
	ora $dd00
	lsr
	lsr
	nop
	ora $dd00
	lsr
	lsr
	eor #$03
	eor $dd00
	lsr
	lsr
	eor #$03
	nop
	eor $dd00
	pha
	lda #$23
	bit $dd00
	sta $dd00
	bvc lend1
	bpl lerr1
	pla
	lda #$42
	jmp $edb2
lerr1	lda #$40	; Too few bytes
	jsr $fe1c	; In Control OS Messages 
lend1	pla
	clc
	rts

; return to vector in a/y+1
returnOut:
	pha
	tya
	pha
lcd27	sei
	lda $d011
	ora #$10
	sta $d011	; enable screen
	lda #$30
	sta $01
	jsr ldaf2	; move helper to 02e1
	jmp l2f6	; swap cb00/db00, cli, exit

; display message, install load vector, exit
lcd6a	pla
	lda #$37
	sta $01
	sta $92
;	lda #$00
;	sta $d021
;	lda #$06
;	sta $d020
	lda #<lcdac
	ldy #>lcdac
	jsr $ab1e	; output string
	lda #<vload
	ldy #>vload
	sta iload
	sty iload+1
	jmp lcd27	; install 02xx helper, swap cb00/db00, exit

; Message
lcdac	.byt $93  ; ,$11,$9e
	.byt "sjload 0.96 - 2009-10-03"
	.byt $0d,$00

	.byt $08
