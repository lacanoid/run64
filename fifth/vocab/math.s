PROC EQ, "=="
  
  SpDec
  GetHi 0
  CmpHi 1
  bne false
  GetLo 0
  CmpLo 1
  bne false
  Insert 1, 1
  NEXT  
  false:
  Insert 1, 0
  NEXT
END

PROC DIV, "/"
  divisor = STACK-2     ;$59 used for hi-byte
  dividend = STACK-4	  ;$fc used for hi-byte
  remainder = STACK 	  ;$fe used for hi-byte
  temp = STACK+2
  result = dividend ;save memory by reusing divident to store the result

  ldx f_SP

  divide:
    lda #0	        ;preset remainder to 0
    sta remainder,x
    sta remainder+1,x
    ldy #16	        ;repeat for each bit: ...

  divloop:
    asl dividend,x	;dividend lb & hb*2, msb -> Carry
    rol dividend+1,x	
    rol remainder,x	;remainder lb & hb * 2 + msb from carry
    rol remainder+1,x
    lda remainder,x
    sec
    sbc divisor,x	;substract divisor to see if it fits in
    sta temp,x       ;lb result -> temp, for we may need it later
    lda remainder+1,x
    sbc divisor+1,x
    bcc skip	;if carry=0 then divisor didn't fit in yet

    sta remainder+1,x	;else save substraction result as new remainder,
    lda temp,x
    sta remainder,x	
    inc result,x	;and INCrement result cause divisor fit in 1 times

    skip:
      dey
      bne divloop	
      dex
      dex
      stx f_SP 
      NEXT
END

PROC MUL, "*"
  multiplier	= STACK-4
  multiplicand	= STACK-2 
  product		= STACK 
  ldx f_SP
  mult16:
    lda	#$00
    sta	product+2,x	; clear upper bits of product
    sta	product+3,x 
    ldy	#$10		; set binary count to 16 
  shift_r:
    lsr	multiplier+1,x	; divide multiplier by 2 
    ror	multiplier,x
    bcc	rotate_r 
    lda	product+2,x	; get upper half of product and add multiplicand
    clc
    adc	multiplicand,x
    sta	product+2,x
    lda	product+3,x 
    adc	multiplicand+1,x
  rotate_r:
    ror			; rotate partial product 
    sta	product+3,x 
    ror	product+2,x
    ror	product+1,x
    ror	product,x
    dey
    bne	shift_r
    lda product,x
    sta multiplier,x
    lda product+1,x
    sta multiplier+1,x
    SpDec
    NEXT
END 

PROC ADD, "+"
  ldx f_SP
  clc
  lda STACK-4,x
  adc STACK-2,x
  sta STACK-4,x

  lda STACK-3,x
  adc STACK-1,x
  sta STACK-3,x
  SpDec
  NEXT
END

PROC SUB, "-"
  ldx f_SP
  sec 
  lda STACK-4,x
  sbc STACK-2,x
  sta STACK-4,x

  lda STACK-3,x
  sbc STACK-1,x
  sta STACK-3,x
  SpDec
  NEXT
END
