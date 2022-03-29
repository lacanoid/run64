
  .scope codegen
    OUTPUT = HEAP_START
    result: .word 0
    
    .proc write_ctl
      RunFrom result
      rts
    .endproc

    .proc write
      WriteA IP
      rts
    .endproc  

    .proc write_int
      lda #bytecode::INT
      jsr write
      jmp write_result
    .endproc

    .proc write_run
      lda #bytecode::RUN
      jsr write
      jmp write_result
    .endproc

    .proc write_result 
      lda result
      jsr write
      lda result+1
      jsr write
      rts 
    .endproc

    .proc write_if
      lda #bytecode::IF0    
      jsr write
      lda #bytecode::IF0
      jsr write_hope
      rts
    .endproc

    .proc write_else
      lda #bytecode::ELS
      jsr write

      ; TODO: check if IF

      lda #bytecode::IF0
      ldy #2
      jsr resolve_hope
      bcs catch

      jsr cdrop

      lda #bytecode::IF0 
      jsr write_hope
      rts
      catch:
        jmp rmismatch
    .endproc

    .proc write_then
      
      lda #bytecode::IF0
      ldy #0
      jsr resolve_hope
      bcs catch

      jsr cdrop

      lda #bytecode::THN
      jsr write
      rts
      catch:
        PrintName cTHEN
        jmp rmismatch
    .endproc

    .proc write_begin
      lda #bytecode::BGN
      jsr write

      lda #bytecode::BGN
      jsr store_ref
      rts
    .endproc

    .proc write_while
      lda #bytecode::WHL
      jsr write
      lda #bytecode::WHL
      jsr write_hope
      rts
    .endproc

    .proc write_again
      lda #bytecode::AGN
      jsr write
      loop:
        lda #bytecode::WHL
        ldy #2
        jsr resolve_hope
        bcs not_while
        jsr cdrop
        jmp loop

        not_while:
        
        lda #bytecode::BGN
        jsr write_ref
        jsr cdrop
        bcs catch
      rts
      catch:
        jmp rmismatch
    .endproc

    .proc write_hope
      jsr store_ref
      IAddB IP,2
      rts 
    .endproc

    .proc store_ref
      ldx csp 
      inx
      inx
      inx
      sta cstack-3,x
      lda IP
      sta cstack-2,x
      lda IP+1
      sta cstack-1,x
      stx csp
      rts 
    .endproc


    .proc resolve_hope
      ldx csp
      beq catch

      cmp cstack-3, x
      bne catch

      IMov temp, IP
      tya 
      IAddA temp
      Stash IP
        IMovIx IP, cstack-2,csp
        lda temp
        jsr write
        lda temp+1
        jsr write
      Unstash IP
      clc
      rts
      catch:
      sec
      rts
      temp: .word 0
    .endproc

    .proc write_ref
      ldx csp
      beq catch
      cmp cstack-3, x
      bne catch

      lda cstack-2, x
      jsr write
      lda cstack-1, x
      jsr write
      clc
      rts 
      catch:
      sec
      rts 
    .endproc

    .proc cdrop
      ldx csp
      txa
      beq catch
      dex
      dex
      dex
      stx csp
      rts 
      catch:
      jmp lmismatch
    .endproc
  .endscope 