.proc print_dec 
    ; Print a 16 bit unsigned binary integer from stack in base 10
    ; Leading zeros are omitted
    ; expects a pointer to stack element in x

    CopyTo 1, result

    PRINT_UINT16:
      LDA      #0                  ; terminator for digits on stack
    PRINT_UINT16_1:
      PHA                         ; push terminator or digit onto stack
      LDA     #0                  ; accumulator for division
      CLV                         ; V flag will be set if any quotient bit is 1
      LDY     #16                 ; number of input bits to process
    PRINT_UINT16_2:
      CMP     #5                  ; is accumulator >= 5 ?
      BCC     PRINT_UINT16_3
      SBC     #$85                ; if so, subtract 5, toggle bit 7 and set V flag (unwanted bit 7 will be shifted out imminently)
      SEC                         ; set C (=next quotient bit)
    PRINT_UINT16_3:
      ROL     result              ; shift quotient bit into X while shifting out next dividend bit into A
      ROL     result+1
      ROL                         ; shift dividend into A
      DEY
      BNE     PRINT_UINT16_2     ; loop until all original dividend bits processed
      ORA     #$30                ; A contains remainder from division by 10 - convert to ASCII digit
      BVS     PRINT_UINT16_1     ; if quotient was not zero, loop back to push digit on stack then divide by 10 again
  PRINT_UINT16_4:
      PHA
      JSR CHROUT
      PLA
      PLA                         ; retrieve next digit from stack (or zero terminator)
      BNE     PRINT_UINT16_4     ; if not terminator, print digit
      RTS
    result: .word 0
.endproc

.proc print_hex
  PrintChr '$'
  GetHi 1
  jsr WRTWO
  GetLo 1
  jsr WRTWO
  rts 
.endproc
