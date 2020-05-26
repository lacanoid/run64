VIC2      = $D000  ; VIC-II base
COLORAM   = $D800  ; color ram

SCROLY  = VIC2+$11
RASTER  = VIC2+$12
SCROLX  = VIC2+$16
VICIRQ  = VIC2+$19 ; VIC Interrupt Flag Register
IRQMASK = VIC2+$1A ; VIC IRQ Mask Register
EXTCOL  = VIC2+$20 ; border color
BGCOL0  = VIC2+$21 ; background color
BGCOL1  = VIC2+$22
BGCOL2  = VIC2+$23

CHROUT    = $FFD2  ; output character
STOP      = $FFE1  ; check for stop key

T1     = $9E    ; Tape pass 1 error log index
T2     = $9F    ; Tape pass 2 error log correction index

TIME   = $A0    ; Software Jiffy Clock (2)
SAL    = $AC    ; Pointer to the Starting Address of a Load/Screen Scrolling (2) (temporary)
EAL    = $AE    ; Pointer to Ending Address of Load (2) (End of Program)

FA     = $BA    ; Current Device Number
FNLEN  = $B7    ; Length of Current Filename
FNADDR = $BB    ; Pointer: Current Filename (2)

VICSCN  = $0400

VICGO64 = VICSCN + 40*22
VICAS64 = VICSCN + 40*15
VICCRTB = VICSCN + 40*20

