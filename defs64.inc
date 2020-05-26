.include "defs.inc"

KEYD   = $0277  ; start of keyboard buffer for C64 screen editor
NDX    = $C6    ; keyboard buffer count for C64 screen editor

TXTTAB = $2B    ; Pointer to the Start of BASIC Program Text
VARTAB = $2D    ; Pointer to the Start of the BASIC Variable Storage Area

CINV   = $0314  ; Vector to IRQ Interrupt Routine
CBINV  = $0316  ; Vector: BRK Instruction Interrupt
NMINV  = $0318  ; Vector: Non-Maskable Interrupt 

