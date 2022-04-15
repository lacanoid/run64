.ifndef ::__PIPE_INCLUDED__
::__PIPE_INCLUDED__=1
.macro pipe fn
  jsr pipe::fn
.endmacro

.scope pipe
  .pushseg
  .data
    buffer: .res 16
  .popseg

  input = _input+1
  output = _output+1
  catch = _catch+1

  _input: jsr $FEED
  bcs eof_or_throw
  rts

  _output: jsr $FEED
  bcs throw
  rts

  eof_or_throw:
  cmp #0
  bne throw
    sec
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
    jsr _input
    dey 
    bne skip_y
    
    rts
  .endproc

  .proc copy_y
    jsr _input
    jsr _output 
    dey 
    bne copy_y 
    rts  
  .endproc 
   
  .proc copy_until
    sta rw+1
    loop:
    jsr _input
    rw:cmp #$A0
    beq end
    jsr _output
    dey 
    bne copy_until
    done:
    lda #0
    jmp _output
    end:
    dey
    jsr skip_y 
    beq done
  .endproc
  .proc buffer_y
    jsr _input
    sta buffer,y
    dey 
    bne buffer_y 
    rts   
  .endproc
  .proc flush_y
      lda buffer,y
      jsr _output 
      dey 
    bne flush_y
    rts  
  .endproc
.endscope
.endif

.scope file
  .proc open
    jsr xy::findz
    jsr SETNAM
    jsr OPEN
  .endproc
.endscope