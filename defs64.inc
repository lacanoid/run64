.include "defs.inc"

KEYD   = $0277  ; start of keyboard buffer for C64 screen editor
NDX    = $C6    ; keyboard buffer count for C64 screen editor
COLOR  = $0286  ; current foreground color

TXTTAB = $2B    ; Pointer to the Start of BASIC Program Text
VARTAB = $2D    ; Pointer to the Start of the BASIC Variable Storage Area
ARYTAB = $2F    ; Pointer to the Start of the BASIC Array Storage Area
STREND = $31    ; Pointer to End of the BASIC Array Storage Area (+1)
FRETOP = $33    ; Pointer to the Bottom of the String Text Storage Area
MEMSIZ = $37    ; Pointer to the Highest Address Used by BASIC

VERCK  = $0A
COUNT  = $0B

C3P0   = $94
BSOUR  = $95
R2D2   = $A3
BSOUR1 = $A4
CMP0   = $B0
TEMP   = $B1

BUF    = $0200  ; Line Editor Input Buffer
ENDIN  = $0259  ; End of input buffer

IERROR = $0300  ; Vector to the Print BASIC Error Message Routine
IMAIN  = $0302  ; Vector to the Main BASIC Program Loop
ICRNCH = $0304  ; Vector to the Routine That Crunches the ASCII Text of Keywords into Tokens
IQPLOP = $0306  ; Vector to the Routine That Lists BASIC Program Token as ASCII Text
IGONE  = $0308  ; Vector to the Routine That Executes the Next BASIC Program Token
IEVAL  = $030A  ; Vector to the Routine That Evaluates a Single-Term Arithmetic Expression

CINV   = $0314  ; Vector to IRQ Interrupt Routine
CBINV  = $0316  ; Vector: BRK Instruction Interrupt
NMINV  = $0318  ; Vector: Non-Maskable Interrupt 

; basic magic api
LINKPRG = $A533
SCRTCH  = $A644
CLEARC  = $A663
