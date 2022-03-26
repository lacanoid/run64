.include "defs.inc"

KEYD    = $034A  ; start of keyboard buffer for C64 screen editor
NDX     = $D0    ; keyboard buffer count for C64 screen editor
COLOR   = $F1    ; current foreground color
XMAX    = $0A20  ; Keyboard Queue Maximum Size

TXTTAB  = $2D    ; (2) Pointer to the Start of BASIC Program Text
VARTAB  = $2F    ; 
ARYTAB  = $31
STREND  = $33
FRETOP  = $35
MEMSIZ  = $39

VERCK   = $0C
COUNT   = $0D

KEYTAB  = $CC    ; Keyscan Table Pointer

BUF     = $0200  ; Line Editor Input Buffer
ENDIN   = $02A2  ; End of input buffer
GDCOL   = $0A2A  ; Color of Character under Cursor
RPTFLG  = $0A22  ; Flag: Which Keys Will Repeat?
KOUNT   = $0A23  ; Counter for Timing the Delay Between Key Repeats
DELAY   = $0A24  ; Counter for Timing the Delay Until the First Key Repeat Begins
LSTSHF  = $0A25  ; Last Pattern of SHIFT/CTRL/Logo Keypress
BLNON	= $0A26	 ; VIC Cursor Mode (Blinking, Solid)
BLNSW   = $0A27  ; VIC Cursor Disable
BLNCT   = $0A28  ; VIC Cursor Blink Counter
VM1		= $0A2C	 ; 2604	VIC Text Screen/Character Base Pointer
VM2		= $0A2D	 ; 2605	VIC Bit-Map Base Pointer
VM3		= $0A2E	 ; 2606	VDC Text Screen Base
VM4		= $0A2F	 ; 2607	VDC Attribute Base
SHFLAG  = $D3    ; Shift key status flag
SFDX    = $D4    ; Current key pressed
LSTX    = $D5    ; Keyscan Last Key Index
CRSW    = $D6    ; <CR> Input Flag	
MODE    = $D7    ; 40/80 Column Mode Flag
RVS     = $F3    ; Reverse Mode Flag

LSXP    = $E8    ; Current Input Column Start
LSTP    = $E9    ; Current Input Line Start
INDX    = $EA    ; Current Input Line End

TBLX    = $EB    ; Current cursor line
PNT     = $E0    ; Pointer to current line (Text)
USER    = $E2    ; Pointer to Current Line (Attribute)
PNTR    = $EC    ; Current cursor column
COLUMNS = $EE    ; Maximum number of screen columns
QTSW    = $F4    ; Flag: Editor in Quote Mode? 0=No
INSRT   = $F5    ; Insert Mode Flag

C64MODE   = $FF4D  ; go 64 mode

IIRQ      = $0314  ; Vector to IRQ Interrupt Routine
IBRK      = $0316  ; Vector: BRK Instruction Interrupt
INMI      = $0318  ; Vector: Non-Maskable Interrupt 


