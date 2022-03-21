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

C3P0   = $94
BSOUR  = $95
R2D2   = $A3
BSOUR1 = $A4
CMP0   = $B0
TEMP   = $B1

TBLX   = $D6    ; Current Cursor Physical Line Number
PNT    = $D1    ; Pointer to the Address of the Current Screen Line RAM Location
DATA   = $D7    ; Temporary Storage Area for ASCII Value of Last Character Printed
USER   = $F3    ; Pointer to the Address of the Current Screen Color RAM Location
KEYTAB = $F5    ; Vector: Keyboard Decode Table
CRSW   = $D0    ; Flag: Input from Keyboard or Screen
PNTR   = $D3    ; Cursor Column on Current Line
QTSW   = $D4    ; Flag: Editor in Quote Mode? 0=No
INSRT  = $D8    ; Flag: Insert Mode (Any Number Greater Than 0 Is the Number of Inserts)
LSTSHF = $028e  ; Last Pattern of SHIFT/CTRL/Logo Keypress

LSTX   = $C5    ; Matrix Coordinate of Last Key Pressed, 64=None Pressed
INDX   = $C8    ; Pointer: End of Logical Line for Input
LSXP   = $C9    ; Cursor X Position at Start of Input
LSTP   = $CA    ; Cursor Y Position at Start of Input

BUF    = $0200  ; Line Editor Input Buffer
ENDIN  = $0259  ; End of input buffer
GDCOL  = $0287  ; Color of Character under Cursor
RVS    = $C7    ; Flag: Print Reverse Characters? 0=No
GDBLN  = $CE    ; Character under Cursor
BLNON  = $CF    ; Flag: Was Last Curson Blink on or off?
BLNCT  = $CD    ; Timer: Countdown to Blink Cursor
RPTFLG = $028A  ; Flag: Which Keys Will Repeat?
KOUNT  = $028B  ; Counter for Timing the Delay Between Key Repeats
DELAY  = $028C  ; Counter for Timing the Delay Until the First Key Repeat Begins
SHFLAG = $028C  ; Shift key status flag
SFDX   = $CB    ; Current key pressed

IERROR = $0300  ; Vector to the Print BASIC Error Message Routine
IMAIN  = $0302  ; Vector to the Main BASIC Program Loop
ICRNCH = $0304  ; Vector to the Routine That Crunches the ASCII Text of Keywords into Tokens
IQPLOP = $0306  ; Vector to the Routine That Lists BASIC Program Token as ASCII Text
IGONE  = $0308  ; Vector to the Routine That Executes the Next BASIC Program Token
IEVAL  = $030A  ; Vector to the Routine That Evaluates a Single-Term Arithmetic Expression

CINV   = $0314  ; Vector to IRQ Interrupt Routine
CBINV  = $0316  ; Vector: BRK Instruction Interrupt
NMINV  = $0318  ; Vector: Non-Maskable Interrupt 

IBASIN = $0324  ;
IBSOUT = $0326  ; 

; basic magic api

LINKPRG = $A533 ; link basic program
SCRTCH  = $A644 ; perform NEW
RUNC    = $A659 ; reset execute pointer
CLEARC  = $A663 ; perform CLEAR
STXTPT  = $A68E ; reset text pointer 
LIST    = $A69C ; perform LIST
RUN     = $A871 ; perform RUN
NEWSTT  = $A7AE ;
LINPRT  = $BDCD ; print XA as unsigned integer

; kernal magic api

RESTOR    = $FD15  ; Restore RAM Vectors for Default I/O Routines
RAMTAS    = $FD50  ; Perform RAM Test and Set Pointers to the Top and Bottom of RAM
IOINIT    = $FDA3  ; Initialize CIA I/O Devices
CINT      = $FF5B  ; Initialize Screen Editor and VIC-II Chip
