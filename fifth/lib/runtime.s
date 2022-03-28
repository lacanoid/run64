.scope rstack
  .align 2 
  IP: .word 0
  STACK: .res 128
  SP: .byte 0
  .proc push
    ;PrintChr '<'
    ldx SP
    lda IP
    sta STACK,x
    lda IP+1
    sta STACK+1,x
    inc SP
    inc SP
    rts 
  .endproc
  .proc pop
    ;PrintChr '>'
    dec SP
    dec SP
    ldx SP
    lda STACK,x
    sta IP
    lda STACK+1,x
    sta IP+1
    rts 
  .endproc
.endscope

.macro RPush 
  jsr rstack::push
.endmacro

.macro RPop arg1
  jsr rstack::pop
.endmacro

.macro Peek address, offset
  IMov TMP, address
  .ifnblank offset
    IAddB TMP, offset
  .endif
  ldx #0
  lda (TMP,x)
.endmacro

.macro Read address
  Peek address
  tax
  IInc address
  txa 
.endmacro

.macro PokeA address, offset
  pha
  IMov TMP, address
  .ifnblank offset
    IAddB TMP, offset
  .endif
  ldx #0
  pla
  sta (TMP,x)
.endmacro

.macro Poke addr1, addr2
  .scope
    pha
    IMov rewrite+1, address
    pla
    rewrite:
    sta $FEDA
  .endscope
.endmacro


.macro Run arg
  ISet runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunFrom arg
  IMov runtime::IP, arg
  jsr runtime::run
.endmacro


.macro rPtr arg
  .byte bytecode::tPTR
  .word arg
.endmacro

.macro rInt arg
  .byte bytecode::tINT
  .word arg
.endmacro

.macro rStr arg
  .scope 
    .byte bytecode::tSTR
    .word next
    .asciiz arg
    next:
  .endscope
.endmacro


.macro rRun arg
  .byte bytecode::tRUN
  .word arg
.endmacro

.macro rRet
  .byte bytecode::tRET
.endmacro


.scope runtime
  ptr = cursor
  IP = rstack::IP

  .proc print_IP
    IPrintHex IP
    rts
  .endproc

  .proc token_code
    Peek IP
    jmp print::print_hex_digits
  .endproc 


  .proc token_id
    Peek IP
    and #15
    tax
    lda table,x
    jmp CHROUT
    table:
      .asciiz "PRISXWCN????J???"
  .endproc 

  .proc token_bytes
    Peek IP
    jsr print::print_hex_digits
    Peek IP

    BraEq #bytecode::tRET, no_payload
    BraEq #bytecode::tSKIP, no_payload

    PrintChr ':'
    Peek IP,1
    sta print::arg
    jsr print::print_hex_digits
    PrintChr ':'
    Peek IP,2
    sta print::arg+1
    jmp print::print_hex_digits
    no_payload:
      lda #' '
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jmp CHROUT
  .endproc 

  .proc token_payload
    Peek IP
    BraEq #bytecode::tRET, no_payload
    BraEq #bytecode::tSKIP, no_payload

    Peek IP,2
    sta print::arg
    jsr print::print_hex_digits
    Peek IP,1
    jsr print::print_hex_digits
    rts

    no_payload:
      lda #' '
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jmp CHROUT
  .endproc 


  .proc describe_token
    ColorPush 12
    jsr token_code
    ColorSet 3
    jsr token_id
    ColorSet 12
    jsr token_payload
    PrintChr ' '
    ColorSet 7
    jsr token_source
    PrintChr 8
    ColorPop
    rts
  .endproc

  .proc token_source
    Peek IP
    and #15
    IfEq #bytecode::tRET
      PrintChr 'R'
      PrintChr 'E'
      PrintChr 'T'
      rts
    EndIf
    IfEq #bytecode::tINT
      Peek IP,1
      sta print::arg
      Peek IP,2
      sta print::arg+1
      jsr print::print_dec
      rts
    EndIf
    IfEq #bytecode::tSTR
      PrintChr '"' ;"
      IMov print::arg, IP
      IAddB print::arg, 3
      jsr print::print_z
      PrintChr '"' ;"
      rts
    EndIf
    IfEq #bytecode::tRUN
      Peek IP,1
      sta print::arg
      Peek IP,2
      sta print::arg+1
      IAddB print::arg, vocab::name_offset
      jsr print::print_z
      rts
    EndIf
    IfEq #bytecode::tIF
      PrintChr 'I'
      PrintChr 'F'
      rts
    EndIf
    rts
  .endproc

  .proc doPtr
    jsr load_ip
    clc
    rts
  .endproc

  .proc doIf
    SpDec
    IsTrue 0
    IfFalse
      jmp doPtr     ; if false move IP to else
    Else 
      IAddB IP, 3   ; otherwise continue
    EndIf
    clc
    rts
  .endproc
  

  .proc doSkip
    clc
    IInc IP
  .endproc

  .proc exec
    IMov ptr, IP
    ldy #0
    lda (ptr),y
    JmpEq #bytecode::tPROC, doProc
    and #15
    JmpEq #bytecode::tPTR, doPtr
    JmpEq #bytecode::tSKIP, doSkip
    JmpEq #bytecode::tRET, doRet
    JmpEq #bytecode::tINT, doInt
    JmpEq #bytecode::tSTR, doStr
    JmpEq #bytecode::tRUN, doRun
    JmpEq #bytecode::tIF, doIf
  .endproc

.proc doStr
  IAddB IP, 3
  
  PushFrom IP
  jmp doPtr
.endproc

.proc doInt
    SpInc
    Peek IP,1
    SetLo 1
    Peek IP,2
    SetHi 1
    IAddB IP,3

    clc
    rts
  .endproc

  .proc doProc  ; only jump and return
    Peek IP,1
    sta rewrite+1
    Peek IP,2
    sta rewrite+2
    rewrite:
    jsr $FEDA
    jmp doRet
  .endproc

  .proc doRun
    IAddB IP,3
    RPush
    jsr load_ip
    ;jsr run
    ;RPop
    clc
    rts
  .endproc 

  .proc doRet
    IfFalse rstack::SP
      inc ended 
    Else 
      RPop
    EndIf
    rts
  .endproc

  .proc load_ip
    iny
    lda (ptr),y
    sta IP
    iny 
    lda (ptr),y
    sta IP+1
    rts
  .endproc 
  ended: .byte 0
  .proc run 
    CClear ended
    Begin
      jsr exec
      BraTrue ended, break
    Repeat
    rts
  .endproc


.endscope
