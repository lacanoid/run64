
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

.macro RReset offset
  .ifblank offset
    lda #0
  .else 
    lda #offset
  .endif
  jsr rstack::reset
.endmacro

.scope rstack
  .align 2 
  IP: .word 0
  STACK: .res 128
  ::RP: .byte 0
  .proc push
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
  ptr = cursor
  IP = rstack::IP

  .proc exec
    ;ReadA IP
    jmp gosub_from_ip
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

  .proc doInt
    ;PrintString "INT"
    SpInc
    ReadA IP
    SetLo 1
    ReadA IP
    SetHi 1
    clc
    rts
  .endproc


  .proc doRet
    IfFalse RP
      inc ended 
    Else 
      RPop
    EndIf
    rts
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

    IfEq #bytecode::NAT
      jmp (tmp) 
    EndIf
    RPush
    PeekA tmp,1
    sta IP
    PeekA tmp,2
    sta IP+1
    rts
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
  ended: .byte 0


  .proc start
    CClear ended
    CClear RP
    rts
  .endproc

  .proc run
    jsr start
  .endproc 
  .proc run_to_end
    Begin
      BraTrue ended, break
      jsr exec
    Again
    rts
  .endproc

  
.endscope
