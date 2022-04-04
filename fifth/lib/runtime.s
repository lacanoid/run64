
.macro RPush offset
  .ifblank offset
    lda #0
  .else 
    lda #offset
  .endif
  jsr rstack::push
.endmacro

.macro RPop arg1
  jsr rstack::pop
.endmacro

.scope rstack
  .align 2 
  ::IP: .word 0
  STACK: .res 128
  ::RP: .byte 0
  .proc push
    ;pha 
    ;  PrintChr'>'
    ;pla 
    clc 
    ldx RP
    add IP
    sta STACK,x
    lda #0
    adc IP+1
    sta STACK+1,x
    inc RP
    inc RP
    rts 
  .endproc
  .proc pop
    ;pha 
    ;  PrintChr'<'
    ;pla 
    dec RP
    dec RP
    ldx RP
    lda STACK,x
    sta IP
    lda STACK+1,x
    sta IP+1
    lda STACK,x
    rts 
  .endproc
.endscope


.scope runtime
  IP = ::IP

  .proc exec
    IfTrue ended 
      PrintString "ALREADY ENDED"
      rts
    EndIf
    jsr gosub_from_ip
    ;jsr print_IP
    rts
  .endproc

  .proc list_entry
    PeekA IP,0
    sta vocab::arg
    PeekA IP,1
    sta vocab::arg+1
    jmp vocab::print_name
  .endproc


  .proc doStr
    IAddB IP, 2
    PushFrom IP
    ISubB IP, 2
    jmp goto_from_ip
  .endproc


  .proc doRet
    jmp EXIT
  .endproc

  .proc doIf
    SpDec
    IsTrue 0
    IfFalse
      jmp goto_from_ip     ; if false move IP to else
    EndIf
    IAddB IP, 2   ; otherwise jump over the pointer?
    clc
    rts
  .endproc

.proc gosub_from_ip  ; only jump and return
    ReadA IP
    sta tmp
    ReadA IP
    sta tmp+1
    PeekA tmp
    IfNe #bytecode::NAT 
      inc runtime::ended
      PrintString "MALFORM"
      rts
    EndIf
    IfTrue creating
      PrintString "COMPILE"
      IAddB tmp, vocab::compile_offset
    EndIf 
    jmp (tmp) 
    tmp:
      .word 0
  .endproc

  .proc goto_from_ip
    ReadA IP
    pha
    ReadA IP
    sta IP+1
    pla
    sta IP
    clc
    rts
  .endproc 
  ended: .byte 1


  .proc reset
    CClear ended
    CClear RP
    rts
  .endproc

  .proc run
    jsr reset
  .endproc

  ::run_to_end:
  .proc run_to_end
    Begin
      BraTrue ended, break
      jsr exec
    Again
    rts
  .endproc

  
.endscope
