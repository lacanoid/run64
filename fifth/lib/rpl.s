.scope rpl 
  f_quit:     .byte 0
  skip_depth: .byte 0
  .proc new_line
    sec
    jsr $e50a
    tya
    IfTrue
      NewLine
    EndIf
    rts
  .endproc 
  .proc do_debug
    ISet runtime::IP, HEAP_START
    ;ISet print::arg, HEAP_START
    ;jsr print::dump_hex
    Begin
      CMov skip_depth, rstack::SP
      inc skip_depth
      ColorPush 3
      jsr debug::print_IP
      CClear runtime::ended
      PrintChr ' '
      ColorPop
      lda rstack::SP
      clc
      ror
      jsr print::print_hex_digits
      PrintChr ' '
      jsr debug::describe_token
      Peek runtime::IP
      IfTrue
        CSet $CC, 0
        wait: jsr GETIN
        beq wait
        and #$7F
        pha
        CSet $CC, 1
        PrintChr ' '
        pla 
        IfEq #'Q'
          jmp exit
        EndIf
        IfEq #'O'
          dec skip_depth
          jmp exec_line
        EndIf
        IfEq #'P'
          inc skip_depth
          jmp exec_line
        EndIf
        IfEq #'R'
          CClear skip_depth
          jmp exec_line
        EndIf
        IfEq #'S'
          jsr new_line
          ColorPush 1
          PrintChr 'S'
          jsr PRINT_STACK
          ColorPop
          jsr new_line
          jmp next_line
        EndIf
        IfEq #'D'
          IMov print::arg, runtime::IP 
          jsr print::dump_hex
          jsr new_line
          jmp next_line
        EndIf
      EndIf
      exec_line:
      jsr new_line
      Begin
        jsr runtime::exec
        BraTrue runtime::ended, exit
        lda skip_depth
        BraGe rstack::SP, break
      Again
      BraTrue runtime::ended, exit
      next_line:
      CMov skip_depth, rstack::SP
      jsr new_line
    Again
    exit:
      jsr new_line
    rts
  .endproc

  .proc do_line
    lda BUF
    IfEq #':'
      jsr compiler::compile_skip_first
      BraTrue compiler::error, catch      
      jsr do_debug
    Else
      jsr compiler::compile
      BraTrue compiler::error, catch 
      NewLine
      Run HEAP_START
    EndIf
    ColorPush 3
    PrintChr 'O'
    PrintChr 'K'
    ColorPop
    rts
    catch:
      ColorPush 10
      PrintChr '?'
      jsr compiler::print_next_word
      ColorPop
      rts 
  .endproc 

  .proc main
    ISet 53280,0
    CMov tmp_color, COLOR
    ColorSet 1
    ClearScreen
    PrintString "5TH 0.1"
    NewLine

    Begin
      ColorSet 1

      jsr getinput

      CMov COLOR, tmp_color
      NewLine

      jsr do_line    

      CMov tmp_color, COLOR
      
      ColorSet 3
      Run PRINT_STACK
      PrintChr ' '
      ColorSet 4      
      ; Run HSIZE
      ; Run DEC
      NewLine
      BraTrue f_quit, break
    Again
    PrintString "BYE."
    rts
    tmp_color: .byte 14
  .endproc 

  .proc getinput 
  ldx #0
  loop:
    jsr CHRIN
    sta BUF,X
    inx
    cpx #ENDIN-BUF   ; error if buffer is full
    bcs ierror
    cmp #13             ; keep reading until CR
  bne loop
  lda #0              ; null-terminate input buffer
  sta BUF-1,X         ; (replacing the CR)
  rts

  ierror:
    PrintString "??"
    rts
  .endproc 

.endscope