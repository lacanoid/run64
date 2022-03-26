
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

.macro rJsr arg
  .byte bytecode::tJSR
  .word arg
.endmacro

.macro rRun arg
  .byte bytecode::tRUN
  .word arg
.endmacro

.macro rRet
  .byte bytecode::tRET
.endmacro

.macro Peek address
  .scope 
    lda address
    sta rewrite+1
    lda address+1
    sta rewrite+1
    rewrite:
    lda $DEF
  .endscope
.endmacro

.macro PokeA address
  .scope 
    pha
    lda address
    sta rewrite+1
    lda address+1
    sta rewrite+2
    pla
    rewrite:
    sta $DEF
  .endscope
.endmacro

.scope runtime
  ptr = cursor
  IP: .word 0
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
    ;IMov print::arg, IP
    ;NewLine
    ;jsr print::print_hex
    IMov ptr, IP
    ldy #0
    lda (ptr),y
    IfEq #bytecode::tJMP, doJmp
    and #15
    IfEq #bytecode::tPTR, doPtr
    IfEq #bytecode::tCTL, doJsr
    IfEq #bytecode::tRET, doRet
    IfEq #bytecode::tINT, doInt
    IfEq #bytecode::tSTR, doStr
    IfEq #bytecode::tJSR, doJsr
    IfEq #bytecode::tRUN, doRun
    IfEq #bytecode::tIF, doIf
    
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
    ;PrintChr 'C'
    jsr indirect_jump
    clc
    rts 
  .endproc

  .proc doJmp
    ;PrintChr 'J'
    
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
