;.include "defs.inc"

KEYD   = $0527  ; start of keyboard buffer for C64 screen editor
NDX    = $EF    ; keyboard buffer count for C64 screen editor
COLOR  = $053B  ; current foreground color
XMAX   = $053F  ; Maximum Keyboard Buffer Size

FNLEN     = $A8       ; Length of Current Filename
SA        = $AD       ; current secondary address (official name SA)
FA        = $AE       ; Current Device Number
FNADR     = $AF       ; (2) Pointer: Current Filename

TXTTAB = $2B    ; Pointer to the Start of BASIC Program Text
VARTAB = $2D    ; Pointer to the Start of the BASIC Variable Storage Area
ARYTAB = $2E    ; Pointer to the Start of the BASIC Array Storage Area
STREND = $31    ; Pointer to End of the BASIC Array Storage Area (+1)
FRETOP = $33    ; Pointer to the Bottom of the String Text Storage Area
MEMSIZ = $37    ; Pointer to the Highest Address Used by BASIC
VARNAM = $45    ; Current BASIC Variable Name
VARPNT = $47    ; Current BASIC Variable Data
