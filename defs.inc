VIC2      = $D000   ; VIC-II register base
COLORAM   = $D800   ; color memory

; -----------------------------------------------------------------------------
; VIC2 registers
SCROLY  = VIC2+$11
RASTER  = VIC2+$12
SPRITEN = VIC2+$15
SCROLX  = VIC2+$16
VICIRQ  = VIC2+$19  ; VIC Interrupt Flag Register
IRQMASK = VIC2+$1A  ; VIC IRQ Mask Register
EXTCOL  = VIC2+$20  ; border color
BGCOL0  = VIC2+$21  ; background color
BGCOL1  = VIC2+$22
BGCOL2  = VIC2+$23


; -----------------------------------------------------------------------------
; kernal entry points
MEMTOP    = $FF99
MEMBOT    = $FF9C 

SETMSG    = $FF90   ; set kernel message control flag
SECOND    = $FF93   ; set secondary address after LISTEN
TKSA      = $FF96   ; send secondary address after TALK
LISTEN    = $FFB1   ; command serial bus device to LISTEN
TALK      = $FFB4   ; command serial bus device to TALK
ACPTR     = $FFA5   ; input byte from serial bus
CIOUT     = $FFA8   ; output byte to serial bus
UNTLK     = $FFAB   ; command serial bus device to UNTALK
UNLSN     = $FFAE   ; command serial bus device to UNLISTEN
OPEN      = $FFC0   ; Open a logical file
CLOSE     = $FFC3   ; Close a logical file
CHKIN     = $FFC6   ; define input channel
CHKOUT    = $FFC9   ; define output channel
CLRCHN    = $FFCC   ; restore default devices
CHRIN     = $FFCF   ; input a line of characters
CHROUT    = $FFD2   ; output character
READST    = $FFB7   ; Read status 
SETLFS    = $FFBA   ; Set file parameters
SETNAM    = $FFBD   ; Set file name parameters
LOAD      = $FFD5   ; load from device
SAVE      = $FFD8   ; save to device
STOP      = $FFE1   ; check for stop key
GETIN     = $FFE4   ; get a character

; -----------------------------------------------------------------------------
; kernal variables
STATUS    = $90        ; kernal i/o status word

T1        = $9E        ; Tape pass 1 error log index
T2        = $9F        ; Tape pass 2 error log correction index

TIME      = $A0        ; (3) Software Jiffy Clock 
SAL       = $AC        ; (2) Pointer to the Starting Address of a Load/Screen Scrolling (temporary)
EAL       = $AE        ; (2) Pointer to Ending Address of Load (End of Program)

FNLEN     = $B7        ; Length of Current Filename
SA        = $B9        ; current secondary address (official name SA)
FA        = $BA        ; Current Device Number
FNADR     = $BB        ; (2) Pointer: Current Filename

; -----------------------------------------------------------------------------
; temporary pointers
TMP0      = $C1        ; used to return input, often holds end address
TMP2      = $C3        ; usually holds start address
; -----------------------------------------------------------------------------

VICSCN    = $0400     ; default screen memory

VICGO64 = VICSCN + 40*22
VICAS64 = VICSCN + 40*15
VICCRTB = VICSCN + 40*20

