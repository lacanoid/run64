.ifndef __DEFS_INCLUDED__
__DEFS_INCLUDED__ = 128

.include "defs.inc"

; keyboard

KEYD    = $034A  ; start of keyboard buffer for C64 screen editor
NDX     = $D0    ; keyboard buffer count for C64 screen editor
COLOR   = $F1    ; current foreground color
XMAX    = $0A20  ; Keyboard Queue Maximum Size

; memory
TXTTAB  = $2D    ; (2) Pointer to the Start of BASIC Program Text
VARTAB  = $2F    ; 
ARYTAB  = $31
STREND  = $33
FRETOP  = $35
MEMSIZ  = $39

; common
VERCK   = $0C
COUNT   = $0D

; editor
KEYTAB  = $CC    ; Keyscan Table Pointer

BUF     = $0200  ; Line Editor Input Buffer
ENDIN   = $02A2  ; End of input buffer
RPTFLG  = $0A22  ; Flag: Which Keys Will Repeat?
KOUNT   = $0A23  ; Counter for Timing the Delay Between Key Repeats
DELAY   = $0A24  ; Counter for Timing the Delay Until the First Key Repeat Begins
LSTSHF  = $0A25  ; Last Pattern of SHIFT/CTRL/Logo Keypress
BLNON	= $0A26	 ; VIC Cursor Mode (Blinking, Solid)
BLNSW   = $0A27  ; VIC Cursor Disable
BLNCT   = $0A28  ; VIC Cursor Blink Counter
GDCOL   = $0A2A  ; Color of Character under Cursor
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

; vectors
IERROR = $0300  ; Vector to the Print BASIC Error Message Routine
IMAIN  = $0302  ; Vector to the Main BASIC Program Loop
ICRNCH = $0304  ; Vector to the Routine That Crunches the ASCII Text of Keywords into Tokens
IQPLOP = $0306  ; Vector to the Routine That Lists BASIC Program Token as ASCII Text
IGONE  = $0308  ; Vector to the Routine That Executes the Next BASIC Program Token
IEVAL  = $030A  ; Vector to the Routine That Evaluates a Single-Term Arithmetic Expression

IIRQ   = $0314  ; Vector to IRQ Interrupt Routine
IBRK   = $0316  ; Vector: BRK Instruction Interrupt
INMI   = $0318  ; Vector: Non-Maskable Interrupt 

ISOFT_RESET = $4004 ; BASIC soft reset vector

; basic magic api
FAST    = $77B6 ; switches to fast mode
SLOW    = $77C7 ; switches to slow mode
BANK15  = $A845 ; switches to bank 15 configuration

LINKPRG = $4F4F ; link basic program
LIST    = $50E2 ; handle LIST
RUN     = $5A9B ; handle RUN
RUNC    = $51F3 ; reset execute pointer
SCRTCH  = $51D9 ; perform NEW
STXTPT  = $5254 ; reset text pointer
;NEWSTT  = $4af6 ; executes the next BASIC statement
JNEWSTT = $AF90 ; executes the next BASIC statement
LINPRT  = $8E32 ; print unsigned integer .a = high .x = low
JRUN_A_PROGRAM = $AF99 ; run a loaded program


; kernal magic api
CRTI      = $FF33  ; return from interrupt
GETCFG    = $FF6B  ; get MMU conf for a bank number
JSRFAR    = $FF6E  ; indirect JSR to other bank
JMPFAR    = $FF71  ; indirect JMP to other bank
INDFET    = $FF74  ; indirect LDA from other bank
INDSTA    = $FF77  ; indirect STA to other bank
INDCMP    = $FF7A  ; indirect CMP to other bank
PRIMM     = $FF7D  ; print immediate
C64_MODE  = $FF4D  ; go 64 mode

.endif