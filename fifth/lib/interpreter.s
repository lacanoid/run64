
.scope stdin
  ::eof: .byte 0
  ptr: .word BUF
  ::read_line:
    ldx #0
    stx eof
    ISet ptr, BUF
    loop:
      jsr CHRIN
      sta BUF,X
      inx
      cpx #ENDIN-BUF   ; error if buffer is full
      bcs ierror
      cmp #13             ; keep reading until CR
    bne loop
    lda #0              ; null-terminate input buffer
    sta BUF-1,X         ; (replacing the CR)
  rts
  ierror:
    PrintString "??"
    rts
  ::read_char:
    lda eof
    bne at_eof
    ReadA ptr
    bne not_eof
    inc eof
    at_eof:
      sec
      lda #0
      rts
    not_eof:
      clc
      rts 
.endScope


.macro DOCOL
  jsr DO_DOCOL
.endmacro

.macro NEXT
  jmp DO_NEXT
  nop
.endmacro

.proc DO_NEXT
  ;jsr print_IP
  ;jsr print_depth

  ; PeekX IP
  ; sta print::arg
  ; PeekX IP,1
  ; sta print::arg+1
  ; jsr print::dump_hex
  ; wait:
  ;  jsr GETIN
  ; beq wait

  IMov rewrite+1,IP
  IAddB IP, 2
  rewrite: 
  jmp ($DEFA)
.endproc


.proc DO_DOCOL
    pla
    sta IP
    pla
    sta IP+1
    IInc IP
    RPush 2
    NEXT
.endproc


.proc EXIT
  RPop
  IfFalse RP
    ;jsr print_IP
    ;PrintString "EXITING"
    ;GetKey
    jmp (IP)
  EndIf
  PrintString "NOT EXITING"
  GetKey
  NEXT
.endproc

DOCOL0 = $20
DOCOL1 = <DO_DOCOL
DOCOL2 = >DO_DOCOL

.scope interpreter
  buf: .res 32
  ::ERROR_CODE:
  error: .byte 0
  ::ERROR_MSG:
  msg: .addr 0   

  .proc read_word
    skip:
      jsr read_char
      bcs at_eof
      cmp #33
    bcc skip
    ldx #0
    loop:
      sta buf,x 
      inx
      cpx #31
      bcs catch
      cmp #'"'
      beq exit
      jsr read_char
      cmp #33
      bcc exit
    bra loop
    exit:
      lda #0
      sta buf,x
      clc
      rts
    catch:
      PrintString "WORD TOO LONG"
      inc eof
      inc error
      rts
    at_eof:
      sec
      rts 
  .endproc 

  .proc try_entry
    CClear RP
    ISet vocab::arg, buf
    jsr vocab::find_entry
    bcs not_found
    IMov entry, vocab::cursor
    ;WPrintHex entry  
    DOCOL
    entry: .word $DEFA
    _ EXIT
    ;PrintString "THIS IS THE WAY"
    ;GetKey
    clc
    rts
    not_found:
    sec
    rts
  .endproc

  .proc try_dec
    ISet parser::arg, buf
    jsr parser::parse_dec
    bcs not_found
    PushFrom parser::result
    clc
    rts 
    not_found:
    sec
    rts
  .endproc

  .proc do_word
    jsr read_word
    bcs at_eof

    jsr try_entry
    bcc done
    jsr try_dec
    bcc done
    ThrowError "NOT FOUND"
    at_eof:
    sec
    rts
    done:
    clc
    rts
  .endproc

  .proc rpl
    
    ISet 53280, 0
    PushA
    lines:
      
      ;jsr PRINT_STACK
      NewLine
      PrintChr 'R'
      PrintChr '>'

      CClear error
      jsr read_line
      NewLine
      
      words:
        jsr do_word
        bcs break
      bra words
      break:
      lda error
      beq lines
      IMov print::arg,msg
      jsr print::print_z
      PrintChr ' '
      PrintChr '?'
      ISet print::arg,buf
      jsr print::print_z
    bra lines

  .endproc

.endScope