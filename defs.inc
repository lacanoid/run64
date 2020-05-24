VIC2      = $D000  ; VIC-II base
COLORAM   = $D800  ; color ram

C64MODE   = $FF4D  ; go 64 mode
CHROUT    = $FFD2  ; output character
STOP      = $FFE1  ; check for stop key

VICSCN  = $0400
VICGO64 = VICSCN + 40*22
VICAS64 = VICSCN + 40*15
VICCRTB = VICSCN + 40*20

SCROLY  = VIC2+$11
SCROLX  = VIC2+$16
EXTCOL  = VIC2+$20
BGCOL0  = VIC2+$21
BGCOL1  = VIC2+$22
BGCOL2  = VIC2+$23
