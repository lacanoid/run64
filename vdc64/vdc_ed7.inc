;	.page
;	.subttl  ed7  tables & data  (08/15/85)

coltab:
	.byte $90,$05,$1c,$9f,$9c,$1e,$1f,$9e		;color key codes
	.byte $81,$95,$96,$97,$98,$99,$9a,$9b

coladj:
.if vdc_colors=1  ; new colors
	.byte $00,$0f,$08,$07,$0b,$04,$02,$0d		;convert rgbi to c64 colors
	.byte $0a,$0c,$09,$01,$06,$05,$03,$0e
.else  ; c128 colors
	.byte $00,$0f,$08,$07,$0b,$04,$02,$0d		;convert rgbi to c64 colors
	.byte $0a,$0c,$09,$06,$01,$05,$03,$0e
.endif

bits:
	.byte $80,$40,$20,$10,$08,$04,$02,$01

localzp:
	.byte $00,$04,$00,$d8,$18,$00,$00,$27		;local variable init table
	.byte $00,$00,$00,$00,$00,$18,$27,$00		;(vic screen)
	.byte $00,$0d,$0d,$00,$00,$00,$00,$00
	.byte $00,$00
localabs:
	.byte $00,$00,$00,$08,$18,$00,$00,$4f		;absolute var init table
	.byte $00,$00,$00,$00,$00,$18,$4f,$00		;(8563 screen)
	.byte $00,$07,$07,$00,$00,$00,$00,$00
	.byte $00,$00

;	.page

.if feature_pfkey=1
pkytbl:				;pre-programmed function key definitions
	.byte pky2-pky1
	.byte pky3-pky2
	.byte pky4-pky3
	.byte pky5-pky4
	.byte pky6-pky5
	.byte pky7-pky6
	.byte pky8-pky7
	.byte runtb-pky8
	.byte helptb-runtb	;<shift><run> is a non-programmable function key
	.byte pkyend-helptb	;<help>       is too


pky1:	.byte "GRAPHIC"
pky2:	.byte "DLOAD"
pky3:	.byte "DIRECTORY",cr
pky4:	.byte "SCNCLR",cr
pky5:	.byte "DSAVE"
pky6:	.byte "RUN",cr
pky7:	.byte "LIST",cr
pky8:	.byte "MONITOR",cr
runtb:	.byte $44,$cc,$22,$2a,cr,"RUN",cr	;dL"* <cr> run <cr>
helptb:	.byte "HELP",cr
pkyend:
.endif

.if feature_scnkey=1

mode1:						;normal keys

	.byte $14,$0d,$1d,$88,$85,$86,$87,$11  ;del ret rt  f7  f1  f3  f5  dn
	.byte $33,$57,$41,$34,$5a,$53,$45,$01  ; 3   w   a   4   z   s   e  shf
	.byte $35,$52,$44,$36,$43,$46,$54,$58  ; 5   r   d   6   c   f   t   x
	.byte $37,$59,$47,$38,$42,$48,$55,$56  ; 7   y   g   8   b   h   u   v
	.byte $39,$49,$4a,$30,$4d,$4b,$4f,$4e  ; 9   i   j   0   m   k   o   n
	.byte $2b,$50,$4c,$2d,$2e,$3a,$40,$2c  ; +   p   l   -   .   :   @   ,
	.byte $5c,$2a,$3b,$13,$01,$3d,$5e,$2f  ;lb.  *   ;  hom shf  =   ^   /
	.byte $31,$5f,$04,$32,$20,$02,$51,$03  ; 1  <-- ctl  2  spc  C=  q stop
	.byte $84,$38,$35,$09,$32,$34,$37,$31  ;hlp (8) (5) tab (2) (4) (7) (1)
	.byte $1b,$2b,$2d,$0a,$0d,$36,$39,$33  ;esc (+) (-)  lf ent (6) (9) (3)
	.byte $08,$30,$2e,$91,$11,$9d,$1d,$ff  ;alt (0) (.) /up /dn /lf /rt scl
	.byte $ff

mode2:						;shifted keys (right keycap graphics)

	.byte $94,$8d,$9d,$8c,$89,$8a,$8b,$91  ;ins RTN lft f8  f2  f4  f6  up
	.byte $23,$d7,$c1,$24,$da,$d3,$c5,$01  ; #   W   A   $   Z   S   E  shf
	.byte $25,$d2,$c4,$26,$c3,$c6,$d4,$d8  ; %   R   D   &   C   F   T   X
	.byte $27,$d9,$c7,$28,$c2,$c8,$d5,$d6  ; '   Y   G   (   B   H   U   V
	.byte $29,$c9,$ca,$30,$cd,$cb,$cf,$ce  ; )   I   J   0   M   K   O   N
	.byte $db,$d0,$cc,$dd,$3e,$5b,$ba,$3c  ;+gr  P   L  -gr  >   [  @gr  <
	.byte $a9,$c0,$5d,$93,$01,$3d,$de,$3f  ;lbg *gr  ]  clr shf  =  pi   ?
	.byte $21,$5f,$04,$22,$a0,$02,$d1,$83  ; !  <-- ctl  "  SPC  C=  Q  run
	.byte $84,$38,$35,$18,$32,$34,$37,$31  ;hlp (8) (5) TAB (2) (4) (7) (1)
	.byte $1b,$2b,$2d,$0a,$8d,$36,$39,$33  ;esc (+) (-)  lf ENT (6) (9) (3)
	.byte $08,$30,$2e,$91,$11,$9d,$1d,$ff  ;alt (0) (.) /up /dn /lf /rt scl
	.byte $ff

mode3:						;C= keys (left keycap graphics)

	.byte $94,$8d,$9d,$8c,$89,$8a,$8b,$91  ;ins RTN lft f8  f2  f4  f6  up
	.byte $96,$b3,$b0,$97,$ad,$ae,$b1,$01  ;red  W   A  cyn  Z   S   E  shf
	.byte $98,$b2,$ac,$99,$bc,$bb,$a3,$bd  ;pur  R   D  grn  C   F   T   X 
	.byte $9a,$b7,$a5,$9b,$bf,$b4,$b8,$be  ;blu  Y   G  yel  B   H   U   V
	.byte $29,$a2,$b5,$30,$a7,$a1,$b9,$aa  ; )   I   J   0   M   K   O   N
	.byte $a6,$af,$b6,$dc,$3e,$5b,$a4,$3c  ;+gr  P   L  -gr  >   [  @gr  <
	.byte $a8,$df,$5d,$93,$01,$3d,$de,$3f  ;lbg *gr  ]  clr shf  =  pi   ?
	.byte $81,$5f,$04,$95,$a0,$02,$ab,$03  ;blk <-- ctl wht spc  C=  Q  run
	.byte $84,$38,$35,$18,$32,$34,$37,$31  ;hlp (8) (5) TAB (2) (4) (7) (1)
	.byte $1b,$2b,$2d,$0a,$8d,$36,$39,$33  ;esc (+) (-)  lf ENT (6) (9) (3)
	.byte $08,$30,$2e,$91,$11,$9d,$1d,$ff  ;alt (0) (.) /up /dn /lf /rt scl
	.byte $ff

mode4:						;control keys

	.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  ; ~   ~   ~   ~   ~   ~   ~   ~
	.byte $1c,$17,$01,$9f,$1a,$13,$05,$ff  ;red /w  /a  cyn /z  /s  /e   ~
	.byte $9c,$12,$04,$1e,$03,$06,$14,$18  ;pur /r  /d  grn /c  /f  /t  /x
	.byte $1f,$19,$07,$9e,$02,$08,$15,$16  ;yel /y  /g  yel /b  /h  /u  /v
	.byte $12,$09,$0a,$92,$0d,$0b,$0f,$0e  ;ron /i  /j  rof /m  /k  /o  /n
	.byte $ff,$10,$0c,$ff,$ff,$1b,$00,$ff  ; ~  /p  /l   ~   ~  /[  /@   ~
	.byte $1c,$ff,$1d,$ff,$ff,$1f,$1e,$ff  ;/lb  ~  /]   ~   ~  /=  /pi  ~
	.byte $90,$06,$ff,$05,$ff,$ff,$11,$ff  ;blk /<-  ~  wht  ~   ~  /q   ~
	.byte $84,$38,$35,$18,$32,$34,$37,$31  ;hlp (8) (5) TAB (2) (4) (7) (1)
	.byte $1b,$2b,$2d,$0a,$8d,$36,$39,$33  ;esc (+) (-)  lf ENT (6) (9) (3)
	.byte $08,$30,$2e,$91,$11,$9d,$1d,$ff  ;alt (0) (.) /up /dn /lf /rt scl
	.byte $ff

mode5:						;caps lock mode

	.byte $14,$0d,$1d,$88,$85,$86,$87,$11  ;del ret rt  f7  f1  f3  f5  dn
	.byte $33,$d7,$c1,$34,$da,$d3,$c5,$01  ; 3   w   a   4   z   s   e  shf
	.byte $35,$d2,$c4,$36,$c3,$c6,$d4,$d8  ; 5   r   d   6   c   f   t   x
	.byte $37,$d9,$c7,$38,$c2,$c8,$d5,$d6  ; 7   y   g   8   b   h   u   v
	.byte $39,$c9,$ca,$30,$cd,$cb,$cf,$ce  ; 9   i   j   0   m   k   o   n
	.byte $2b,$d0,$cc,$2d,$2e,$3a,$40,$2c  ; +   p   l   -   .   :   @   ,
	.byte $5c,$2a,$3b,$13,$01,$3d,$5e,$2f  ;lb.  *   ;  hom shf  =   ^   /
	.byte $31,$5f,$04,$32,$20,$02,$d1,$03  ; 1  <-- ctl  2  spc  C=  q stop
	.byte $84,$38,$35,$09,$32,$34,$37,$31  ;hlp (8) (5) tab (2) (4) (7) (1)
	.byte $1b,$2b,$2d,$0a,$0d,$36,$39,$33  ;esc (+) (-)  lf ent (6) (9) (3)
	.byte $08,$30,$2e,$91,$11,$9d,$1d,$ff  ;alt (0) (.) /up /dn /lf /rt scl
	.byte $ff

.endif
