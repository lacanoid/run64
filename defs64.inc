.ifndef __DEFS_INCLUDED__
__DEFS_INCLUDED__ = 64

.include "defs.inc"

KEYD   = $0277  ; start of keyboard buffer for C64 screen editor
NDX    = $C6    ; keyboard buffer count for C64 screen editor
COLOR  = $0286  ; current foreground color
XMAX   = $0289  ; Maximum Keyboard Buffer Size

TXTTAB = $2B    ; Pointer to the Start of BASIC Program Text
VARTAB = $2D    ; Pointer to the Start of the BASIC Variable Storage Area
ARYTAB = $2F    ; Pointer to the Start of the BASIC Array Storage Area
STREND = $31    ; Pointer to End of the BASIC Array Storage Area (+1)
FRETOP = $33    ; Pointer to the Bottom of the String Text Storage Area
MEMSIZ = $37    ; Pointer to the Highest Address Used by BASIC
VARNAM = $45    ; Current BASIC Variable Name

VERCK  = $0A
COUNT  = $0B

CMP0   = $B0
TEMP   = $B1

CRSW   = $D0    ; Flag: Input from Keyboard or Screen
PNT    = $D1    ; Pointer to the Address of the Current Screen Line RAM Location
PNTR   = $D3    ; Cursor Column on Current Line
QTSW   = $D4    ; Flag: Editor in Quote Mode? 0=No
TBLX   = $D6    ; Current Cursor Physical Line Number
DATA   = $D7    ; Temporary Storage Area for ASCII Value of Last Character Printed
INSRT  = $D8    ; Flag: Insert Mode (Any Number Greater Than 0 Is the Number of Inserts)
USER   = $F3    ; Pointer to the Address of the Current Screen Color RAM Location
KEYTAB = $F5    ; Vector: Keyboard Decode Table
LSTSHF = $028e  ; Last Pattern of SHIFT/CTRL/Logo Keypress

LSTX   = $C5    ; Matrix Coordinate of Last Key Pressed, 64=None Pressed
INDX   = $C8    ; Pointer: End of Logical Line for Input
LSXP   = $C9    ; Cursor X Position at Start of Input
LSTP   = $CA    ; Cursor Y Position at Start of Input
SFDX   = $CB    ; Current key pressed

BUF    = $0200  ; Line Editor Input Buffer
ENDIN  = $0259  ; End of input buffer
GDCOL  = $0287  ; Color of Character under Cursor
RVS    = $C7    ; Flag: Print Reverse Characters? 0=No
BLNSW  = $CC    ; Cursor Blink Enable: 0=Flash Cursor
BLNCT  = $CD    ; Timer: Countdown to Blink Cursor
GDBLN  = $CE    ; Character under Cursor
BLNON  = $CF    ; Flag: Was Last Curson Blink on or off?
RPTFLG = $028A  ; Flag: Which Keys Will Repeat?
KOUNT  = $028B  ; Counter for Timing the Delay Between Key Repeats
DELAY  = $028C  ; Counter for Timing the Delay Until the First Key Repeat Begins
SHFLAG = $028C  ; Shift key status flag

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
CINV   = IIRQ
CBINV  = IBRK
NMINV  = INMI

IBASIN = $0324  ;
IBSOUT = $0326  ; 


ISOFT_RESET = $A002 ; basic soft reset (after BRK or RESTORE)

; basic magic api

LINKPRG = $A533 ; rellink basic program
SCRTCH  = $A644 ; perform NEW
RUNC    = $A659 ; reset execute pointer
CLEARC  = $A663 ; perform CLEAR
STXTPT  = $A68E ; reset text pointer 
LIST    = $A69C ; perform LIST
RUN     = $A871 ; perform RUN
NEWSTT  = $A7AE ; executes the next BASIC statement

LINPRT  = $BDCD ; print unsigned integer .a = high .x = low
STROUT  = $AB1E ; Print a string whose Address Is in the .Y (hi) and .A (lo) Registers


; kernal magic api

RESTOR    = $FD15  ; Restore RAM Vectors for Default I/O Routines
RAMTAS    = $FD50  ; Perform RAM Test and Set Pointers to the Top and Bottom of RAM
IOINIT    = $FDA3  ; Initialize CIA I/O Devices
CINT      = $FF5B  ; Initialize Screen Editor and VIC-II Chip

.endif