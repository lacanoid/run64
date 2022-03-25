
.macro _ arg
  .if .blank ({arg}) 
    rRet
  .elseif (.match (.left (1, {arg}), #))
    rInt (.right (.tcount ({arg})-1, {arg}))
  .else 
    rRun arg 
  .endif
.endmacro

.macro __ name, label
  .if .blank ({name}) 
    rRet
    next:
    .endscope
  .elseif .blank({label})
    .scope
    rEntry name
  .else
    .scope
    rEntry name,label
  .endif
.endmacro

.macro DEF name, label
  .scope
    rEntry name, label
.endmacro

.macro DATA
  rRet
  data:
.endmacro

.macro END name, label
    .ifndef data 
      rRet
    .endif
    next:
  .endScope
.endmacro

.macro Run arg
  ISet runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunFrom arg
  IMov runtime::IP, arg
  jsr runtime::run
.endmacro


.macro IF 
  ;.out .sprintf ("IF %d",@then)
  .scope
  .byte runtime::_IF
  .word else
.endmacro

.macro ELSE 
  .byte runtime::_PTR
  .word endif
  else:
.endmacro

.macro ENDIF
  .ifndef else
    else:
  .endif
    endif:
  .endscope
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
  .byte runtime::_STR
  .word arg
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


.macro cEnd
  .word runtime::end
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

  .proc exec
    IMov ptr, IP
    ldy #0
    lda (ptr),y

    IfEq #_PTR, doPtr
    IfEq #_RET, doRet
    IfEq #_INT, doInt
    ;IfEq #_STR, doStr
    IfEq #_JSR, doJsr
    IfEq #_JMP, doJmp
    IfEq #_RUN, doRun
    IfEq #_IF, doIf
    BRK
    sec
    rts
  .endproc

  .proc doIf
    SpLoad
    GetLo 1
    bne then
    GetHi 1
    bne then
    jmp doPtr
    then:
    IAddB IP, 3
    clc
    rts
  .endproc
  
  .proc doRet
    ;PrintChr 'R'
    sec
    rts
  .endproc


  .proc doPtr
    ;PrintChr 'P'
    iny
    lda (ptr),y
    sta IP
    iny 
    lda (ptr),y
    sta IP+1
    clc
    rts
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
    iny
    lda (ptr),y
    sta IP
    iny 
    lda (ptr),y
    sta IP+1
    jsr run
    Unstash IP
    clc
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
