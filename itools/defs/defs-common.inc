VICREG    = $D000   ; VIC-II register base
VICSCN    = $0400   ; default screen memory
COLORAM   = $D800   ; color memory

; -----------------------------------------------------------------------------
; VIC2 registers
SCROLY  = VICREG+$11
RASTER  = VICREG+$12
SPRITEN = VICREG+$15
SCROLX  = VICREG+$16
VICIRQ  = VICREG+$19  ; VIC Interrupt Flag Register
IRQMASK = VICREG+$1A  ; VIC IRQ Mask Register
EXTCOL  = VICREG+$20  ; border color
BGCOL0  = VICREG+$21  ; background color
BGCOL1  = VICREG+$22
BGCOL2  = VICREG+$23


; -----------------------------------------------------------------------------
; kernal entry points
; irq
UDTIM     = $FFEA
SCNKEY    = $FF9F
; config
MEMTOP    = $FF99
MEMBOT    = $FF9C 

SETMSG    = $FF90   ; set kernel message control flag
STOP      = $FFE1   ; check for stop key

SCREEN    = $FFED   ; Return screen format
PLOT      = $FFF0   ; Set cursor location
; serial
SECOND    = $FF93   ; set secondary address after LISTEN
TKSA      = $FF96   ; send secondary address after TALK
LISTEN    = $FFB1   ; command serial bus device to LISTEN
TALK      = $FFB4   ; command serial bus device to TALK
ACPTR     = $FFA5   ; input byte from serial bus
CIOUT     = $FFA8   ; output byte to serial bus
UNTLK     = $FFAB   ; command serial bus device to UNTALK
UNLSN     = $FFAE   ; command serial bus device to UNLISTEN
; files
SETLFS    = $FFBA   ; Set file parameters
SETNAM    = $FFBD   ; Set file name parameters

OPEN      = $FFC0   ; Open a logical file
CLOSE     = $FFC3   ; Close a logical file
CHKIN     = $FFC6   ; define input channel
CHKOUT    = $FFC9   ; define output channel
CLRCHN    = $FFCC   ; restore default devices
CHRIN     = $FFCF   ; input a line of characters 
GETIN     = $FFE4   ; get a character
CHROUT    = $FFD2   ; output character
READST    = $FFB7   ; Read status 

LOAD      = $FFD5   ; load from device
SAVE      = $FFD8   ; save to device


; -----------------------------------------------------------------------------
; kernal variables
STATUS    = $90        ; kernal i/o status word

DFLTN     = $99        ; Default Input Device #
DFLTO     = $9A        ; Default Output Device #

T1        = $9E        ; Tape pass 1 error log index
T2        = $9F        ; Tape pass 2 error log correction index

C3P0      = $94
BSOUR     = $95
R2D2      = $A3
BSOUR1    = $A4
BUFPT     = $A6        ; Count of Characters in (Tape) I/O Buffer

TIME      = $A0        ; (3) Software Jiffy Clock 
SAL       = $AC        ; (2) Pointer to the Starting Address of a Load/Screen Scrolling (temporary)
EAL       = $AE        ; (2) Pointer to Ending Address of Load (End of Program)


FNLEN     = $B7        ; Length of Current Filename
SA        = $B9        ; current secondary address (official name SA)
FA        = $BA        ; Current Device Number
FNADR     = $BB        ; (2) Pointer: Current Filename

; -----------------------------------------------------------------------------
; temporary ZP vars
TMP0      = $C1        ; used to return input, often holds end address
TMP1      = $C2        ;
TMP2      = $C3        ; usually holds start address
TMP3      = $C4        ;
; -----------------------------------------------------------------------------