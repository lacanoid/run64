.proc print_rstack
 ldx RP
  NewLine
  loop:
    cpx #0
    beq done 

    lda #' '
    jsr CHROUT
    
    dex
    lda rstack::STACK,x
    sta print::arg+1
    dex
    lda rstack::STACK,x
    sta print::arg
    jsr print::print_hex
    clc 
    bcc loop
  done:
  NewLine
  rts
.endproc

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


.macro NEXT
  jmp DO_NEXT
.endmacro

.proc DO_NEXT
  .if 1
    PrintString "NEXT"
    jsr print_IP
    jsr print_depth
    jsr print_rstack
    PeekX IP,0
    sta print::arg
    PeekX IP,1
    sta print::arg+1
    ;ISubB print::arg,2
    jsr print::dump_hex
    wait:
      jsr GETIN
    beq wait
  .endif
  IMov rewrite+1,IP
  IAddB IP, 2
  rewrite: 
  jmp ($DEFA)
.endproc

.macro DOCOL
  jsr DO_DOCOL
.endmacro

.proc DO_DOCOL
  RPush 
  ;WPrintHex THEEND
  pla
  sta IP
  pla
  sta IP+1
  IInc IP
  NEXT
.endproc

.proc DONE
  IMov rewrite+1, IP
  ;IInc rewrite+1
  RPop
  rewrite:
  jmp $FEDA
.endproc

.scope interpreter
  buf: .res 32
  ::STATE: .byte 0
  ::ERROR_CODE:
  error: .byte 0
  ::ERROR_MSG:
  msg: .addr 0
  runtime_color: .byte 0   

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
    ISet vocab::arg, buf
    jsr vocab::find_entry
    bcs not_found

    lda STATE
    beq interpret
    PeekX vocab::cursor, vocab::flags_offset
    and vocab::is_immediate
    bne interpret

    compile:
      lda vocab::cursor
      jsr here::write
      lda vocab::cursor+1
      jsr here::write
      clc
      rts  
    interpret:
      IMov entry, vocab::cursor
      DOCOL
        entry: .word $DEFA
      _ DONE
    
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
    ColorSave runtime_color
    ISet 53280, 0
    PushA
    lines:
      ColorSet 1
      DOCOL
      _ PRINT_STACK
      _ DONE

      NewLine
      IfTrue STATE
        PrintChr 'C'
      Else 
        PrintChr 'I'
      EndIf
      PrintChr '>'

      CClear error
      jsr read_line
      NewLine
      ColorRestore runtime_color
      words:
        jsr do_word
        bcs break
      bra words
      break:
      ColorSave runtime_color
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
