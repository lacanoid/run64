
.proc LS
    Entry "LS"
    Mov8 TMP0,FA
    Mov8 STATUS,0
    jsr DIRECT
    Mov8 TMP0,FA
    jsr INSTAT
    rts 
    next:
.endproc

.proc _DSTAT
    Entry "DSTAT"
    Mov8 STATUS,0
    Mov8 TMP0,FA
    jsr CHGDEV
    rts 
    next:
.endproc
