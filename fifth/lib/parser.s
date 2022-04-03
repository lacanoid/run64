.scope parser
  arg: .word 0
  temp: .word 0
  result: .word 0

  .proc parse_dec
    IClear result
    ldx #0
    dec_digit:
    
      ; jsr input::read
      ReadX arg
      and #$7f
      
      BraLt #33, done

      sub #'0'

      BraNeg catch
      BraGe #10, catch
      
      pha
        IMov temp, result
      pla

      IShiftLeft result
      IShiftLeft result
      pha
        IAdd result, temp
      pla
      IShiftLeft result
      BCS catch
      IAddA result 
      jmp dec_digit

    catch:
      ThrowError "DEC"
    done:
      clc
      rts
  .endproc ; parse_dec
.endscope
