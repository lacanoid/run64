.include "defs.inc"

KEYD   = $034A  ; start of keyboard buffer for C64 screen editor
NDX    = $D0    ; keyboard buffer count for C64 screen editor
COLOR  = 241    ; current foreground color

TXTTAB = $2D    ; (2) Pointer to the Start of BASIC Program Text
VARTAB = $2F    ; 
ARYTAB = $31
STREND = $33
FRETOP = $35
MEMSIZ = $39

VERCK  = $0C
COUNT  = $0D

C64MODE   = $FF4D  ; go 64 mode



