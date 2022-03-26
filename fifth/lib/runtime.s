
.macro Run arg
  ISet runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunFrom arg
  IMov runtime::IP, arg
  jsr runtime::run
.endmacro


.macro rPtr arg
  .byte runtime::_PTR
  .word arg
.endmacro

.macro rInt arg
  .byte runtime::_INT
  .word arg
.endmacro

.macro rStr arg
  .scope 
    .byte runtime::_STR
    .word next
    .asciiz arg
    next:
  .endscope
.endmacro

.macro rJsr arg
  .byte runtime::_JSR
  .word arg
.endmacro

.macro rRun arg
  .byte runtime::_RUN
  .word arg
.endmacro

.macro rRet
  .byte runtime::_RET
.endmacro

.scope runtime
  ptr = cursor
  IP: .word 0
  INST: .byte 0
  _PTR = 0
  _RET = $FF
  _INT = $AA
  _STR = 3
  _JSR = 4
  _RUN = $EE
  _IF = $CC
  _JMP = $4C

  .proc doPtr
    ;PrintChr 'P'
    jsr load_ip
    clc
    rts
  .endproc

  .proc doIf
    SpLoad
    SpDec
    IsTrue 0
    beq doPtr     ; if false move IP to else
    IAddB IP, 3   ; otherwise continue
    clc
    rts
  .endproc
  
  .proc doRet
    ;PrintChr 'R'
    sec
    rts
  .endproc

  .proc exec
    IMov ptr, IP
    ldy #0
    lda (ptr),y

    IfEq #_PTR, doPtr
    IfEq #_RET, doRet
    IfEq #_INT, doInt
    IfEq #_STR, doStr
    IfEq #_JSR, doJsr
    IfEq #_JMP, doJmp
    IfEq #_RUN, doRun
    IfEq #_IF, doIf
    sec
    rts
  .endproc

.proc doStr
  IAddB IP, 3
  SpLoad
  PushFrom IP
  jmp doPtr
.endproc

.proc doInt
    IAddB IP, 3
    ;PrintChr 'I'
    SpLoad
    SpInc
    iny
    lda (ptr),y
    SetLo 1
    iny
    lda (ptr),y
    SetHi 1
    clc
    rts
  .endproc

  .proc doJsr
    jsr indirect_jump
    clc
    rts 
  .endproc

  .proc doJmp
    jsr indirect_jump
    sec
    rts 
  .endproc

  .proc doRun
    ;PrintChr 'X'
    IAddB IP,3
    Stash IP
    jsr load_ip
    jsr run
    Unstash IP
    clc
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

  .proc load_to_stack
    iny
    lda (ptr),y
    sta IP
    iny 
    lda (ptr),y
    sta IP+1
    rts
  .endproc 


  .proc indirect_jump
    IAddB IP, 3
    iny
    lda (ptr),y
    sta rewrite+1
    iny 
    lda (ptr),y
    sta rewrite+2
    rewrite:
    jsr 0
    rts 
  .endproc

  .proc run 
    loop:
      jsr exec
    bcc loop
    rts
  .endproc


.endscope
