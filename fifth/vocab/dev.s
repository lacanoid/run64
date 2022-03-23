
.proc VLIST
    Entry "VLIST"
    jsr vocab__reset_cursor
    
    print_entry:
        ldy #5
        print_char:
            lda (cursor),y
            jsr CHROUT
            cmp #33
            bcc chars_done
            iny 
            bne print_char
        chars_done:
        NewLine
        jsr vocab__advance_cursor
        bne print_entry
    
    rts
    next:
.endproc

.proc WHITE
    Entry "WHITE"
    jsr INK
    SpLoad
    Push $1
    jsr POKE
    rts
    next:
.endproc

.proc INK
  Entry "INK"
  SpLoad
  Push $286
  rts 
  next:
.endproc

.proc POKE
  Entry "POKE"
  SpLoad
  CopyTo 2,TMP
  GetLo 1
  
  ldy #0
  sta (TMP),y

  SpDec
  SpDec
  
  rts 
  next:
.endproc

.proc PEEK
    Entry "PEEK"
    SpLoad
    CopyTo 1,TMP
    ldy #0
    lda (TMP),y
    InsertA 1
    rts 
    next:
.endproc

.proc QUIT
    Entry "QUIT"
    inc f_quit
    rts 
    next:
.endproc

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
