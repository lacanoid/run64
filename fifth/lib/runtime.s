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
  _RET = 1
  _INT = 2
  _STR = 3
  _JSR = 4
  _RUN = 5

  .proc exec
    IMov ptr, IP
    ldy #0
    lda (ptr),y

    IfEq #_PTR, doPtr
    IfEq #_RET, doRet
    IfEq #_INT, doInt
    ;IfEq #_STR, doStr
    IfEq #_JSR, doJsr
    IfEq #_RUN, doRun
    brk
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
    IAddB IP, 3
    ;PrintChr 'J'
    iny
    lda (ptr),y
    sta rewrite+1
    iny 
    lda (ptr),y
    sta rewrite+2
    rewrite:
    jsr 0
    clc
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

  .proc run 
    loop:
      jsr exec
    bcc loop
    rts
  .endproc


.endscope
