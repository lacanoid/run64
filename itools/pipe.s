.ifndef ::__PIPE_INCLUDED__
::__PIPE_INCLUDED__=1

.macro pipe fn
  jsr pipe::fn
.endmacro

.scope pipe
  .pushseg
  .data
    buffer: .res 16
    cnt: .byte 0
  .popseg

  input = _input+1
  output = _output+1
  catch = _catch+1

  _input: jsr $FEED
  bcs throw
  rts

  _output: jsr $FEED
  bcs throw
  rts

  throw:
    sta rwerr+1
    pla
    pla
    pla
    pla
    rwerr: lda #$00
    sec
    _catch: jmp $FEED

  .proc set_input
    stxy input
    rts 
  .endproc 
  .proc set_output
    stxy output
    rts 
  .endproc 
  .proc set_catch
    stxy catch
    rts 
  .endproc 

  .proc read
    jsr _input
    rts
  .endproc 

  .proc write
    jsr _input
    rts
  .endproc 

  .proc skip_y
    sty cnt
    loop:
      jsr _input
      dec cnt
    bne loop
    rts
  .endproc

  .proc copy_all
    loop: 
      jsr _input
      jsr _output 
    bne loop
    rts  
  .endproc 

  .proc copy_y
    sty cnt
    loop: 
      jsr _input
      jsr _output 
      dec cnt
    bne loop
    rts  
  .endproc 
   
  .proc copy_until
    sty cnt
    sta rw+1
    loop:
    jsr _input
    rw: cmp #$A0
    beq end
    jsr _output
    dec cnt
    bne loop
    done:
      lda #0
      jmp _output
    end:
      dec cnt
    skip:
      jsr _input
      dec cnt
    bne skip    
    beq done
  .endproc

  .proc buffer_y
    sty cnt
    loop:
      jsr _input
      ldy cnt
      sta buffer,y
      dec cnt
    bne loop
    rts   
  .endproc
  .proc flush_y
    sty cnt
    loop:
      ldy cnt
      lda buffer,y
      jsr _output 
      dec cnt
    bne loop
    rts  
  .endproc
.endscope
.endif
