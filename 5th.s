.include "defs64.inc"
cursor = $FB
input = BUF
TMP = $FD
.macro PUSH arg
    ldx SP
    lda #<arg
    sta STACK,x
    inx
    lda #>arg
    sta STACK,x
    inx
    stx SP 
.endmacro

.macro chrout char
    pha
    lda #char
    jsr CHROUT
    pla
.endmacro

jmp main

_dbottom:

.macro entry name
    .local exec
    clc 
    bcc exec 
    .word next
    .asciiz name
    exec:
.endmacro

.proc VLIST
    entry "VLIST"
    jsr reset_cursor
    
    print_entry:
        ldy #5
        print_char:
            lda (cursor),y
            jsr CHROUT
            cmp #33
            bcc chars_done
            iny 
            bne print_char
        chars_done:
        jsr CRLF
        jsr advance_cursor
        bne print_entry
    
    rts
    next:
.endproc

.proc WHITE
    entry "WHITE"
    jsr INK
    PUSH $1
    jsr POKE
    rts
    next:
.endproc

.proc INK
    entry "INK"
    PUSH $286
    rts
    next:
.endproc

.proc POKE
    entry "POKE"
    ldx SP
    lda STACK-4,x
    sta TMP
    lda STACK-3,x
    sta TMP+1
    lda STACK-2,x
    ldy #0
    sta (TMP),y
    dex
    dex
    dex
    dex
    stx SP
    rts
    next:
.endproc

.proc PEEK
    entry "PEEK"
    ldx SP
    lda STACK-2,x
    sta TMP
    lda STACK-1,x
    sta TMP+1
    lda #0
    tay
    sta STACK-1,x
    lda (TMP),y
    sta STACK-2,x
    rts
    next:
.endproc

.proc DIV
    entry "/"
    divisor = STACK-2     ;$59 used for hi-byte
    dividend = STACK-4	  ;$fc used for hi-byte
    remainder = STACK 	  ;$fe used for hi-byte
    temp = STACK+2
    result = dividend ;save memory by reusing divident to store the result

    ldx SP

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
        stx SP 
        rts
    next:
.endproc
.proc MUL
    entry "*"

    multiplier	= STACK-4
    multiplicand	= STACK-2 
    product		= STACK 
    
    ldx SP
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
        dex
        dex
        stx SP

        rts
    next:
.endproc
.proc ADD 
    entry "+"

    ldx SP
    clc 
    lda STACK-4,x
    adc STACK-2,x
    sta STACK-4,x
    lda STACK-3,x
    adc STACK-1,x
    sta STACK-3
    dex
    dex
    stx SP 
    rts
    next:
.endproc
.proc SUB 
    entry "-"

    ldx SP
    sec 
    lda STACK-4,x
    sbc STACK-2,x
    sta STACK-4,x
    lda STACK-3,x
    sbc STACK-1,x
    sta STACK-3
    dex
    dex
    stx SP 
    rts
    next:
.endproc

.proc DROP
    entry "DROP"
    ldx SP
    dex
    dex 
    stx SP
    rts
    next:
.endproc


.proc DUP
    entry "DUP"
    ldx SP
    lda STACK-2,x
    sta STACK,x
    inx 
    lda STACK-2,x
    sta STACK,x
    inx 
    stx SP
    rts
    next:
.endproc

.proc _SP
    entry "SP"
    lda SP
    jsr WRTWO
    rts
    next:
.endproc

.proc _STACK
    entry ".S"
    lda #'('
    jsr CHROUT
    lda SP
    lsr
    jsr WRTWO 
    lda #')'
    jsr CHROUT

    ldx SP 
    loop:
        cpx #1
        bcc done 

        lda #' '
        jsr CHROUT
        
        lda #'$'
        jsr CHROUT
        lda STACK-1,x
        jsr WRTWO
        lda STACK-2,x
        jsr WRTWO
        dex
        dex
        clc 
        bcc loop

    done:
        jsr CRLF
        rts
    next:
.endproc


.proc HEX
    entry ".$"

    lda #'$'
    jsr CHROUT
    ldx SP
    dex
    lda STACK,x
    jsr WRTWO
    dex
    lda STACK,x
    jsr WRTWO
    stx SP
    rts
    next:
.endproc

.proc DEC
    entry "."
    
    X0=STACK-2
    X1=STACK-1
    ldx SP 
    ; Print a 16 bit unsigned binary integer in base 10
    ; Leading zeros are omitted

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
      ROL     X0,x                  ; shift quotient bit into X while shifting out next dividend bit into A
      ROL     X1,x
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
      dex
      dex
      stx SP
      RTS  
    next=0     
.endproc 

.proc print_dec ; expects SP in x
    X0=STACK-2
    X1=STACK-1

    ; Print a 16 bit unsigned binary integer in base 10
    ; Leading zeros are omitted

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
      ROL     X0,x                  ; shift quotient bit into X while shifting out next dividend bit into A
      ROL     X1,x
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
      dex
      dex
      stx SP
      RTS  
    next=0     
.endproc 

.proc interpret
    lda #0
    sta eof
    loop:
    jsr next_word
    lda eof
    beq loop
    rts
.endproc

.proc next_word

    ldx offset
    skip_space:
        lda input,x
        bne @ss1
    @ss2:
        inc eof
        rts
    @ss1:
        cmp #13
        beq @ss2
        cmp #33
        bcs skipped_space
        inx
        jmp skip_space
    skipped_space:
        stx offset


    lda input,x
    cmp #'$'
        bne not_hex
        jsr parse_hex 
        rts
    not_hex:
    cmp #'0'
        bcc not_dec
    cmp #'9'
        bcs not_dec
        jsr parse_dec
        rts
    not_dec:
        jsr parse_entry
        rts 
.endproc

.proc parse_hex
    lda #0
    sta hex_result
    sta hex_result+1

    hex_digit:

        inx

        lda input,x
        and #$7f
        
        cmp #33
        bcc hex_done

        sec 
        sbc #$30
        bmi hex_error
        cmp #10
        bcc hex_found

        sec
        sbc #7
        cmp #9
        bcc hex_error
        cmp #15
        bcs hex_error

    hex_found:
        ASL hex_result
        ROL hex_result+1

        ASL hex_result
        ROL hex_result+1

        ASL hex_result
        ROL hex_result+1

        ASL hex_result
        ROL hex_result+1

        BCS hex_error
        
        ORA hex_result
        STA hex_result
        BCC hex_digit

    hex_error:
        lda #'$'
        jsr CHROUT
        lda #'?'
        jsr CHROUT
        lda input,x
        jsr CHROUT
        inc eof
        rts 

    hex_done:
        stx offset

        ldx SP
        lda hex_result
        sta STACK,x
        inx 
        lda hex_result+1
        sta STACK,x
        inx 
        stx SP 
        rts 

.endproc ; parse_hex

.proc parse_dec
    lda #0
    sta hex_result
    sta hex_result+1
    dex
    dec_digit:

        inx

        lda input,x
        and #$7f
        
        cmp #33
        bcc dec_done

        sec 
        sbc #$30
        bmi dec_error
        cmp #10
        bcs dec_error

        

        pha
        lda hex_result
        sta temp
        lda hex_result+1
        sta temp+1
        pla

        ASL hex_result
        ROL hex_result+1
        ASL hex_result
        ROL hex_result+1

        pha
        clc
        lda hex_result
        adc temp
        sta hex_result
        lda hex_result+1
        adc temp+1
        sta hex_result+1
        pla

        ASL hex_result
        ROL hex_result+1

        BCS dec_error
        nomul:
        ADC hex_result
        
        STA hex_result
        BCC dec_digit

    dec_error:
        lda #'0'
        jsr CHROUT
        lda #'?'
        jsr CHROUT
        lda input,x
        jsr CHROUT
        inc eof
        rts 

    dec_done:
        stx offset

        ldx SP
        lda hex_result
        sta STACK,x
        inx 
        lda hex_result+1
        sta STACK,x
        inx 
        stx SP 
        rts 

    temp: .word 0
.endproc ; parse_hex


.proc parse_entry
    jsr reset_cursor

    match_entry:

        ldy #5
        ldx offset

        next_char:
            lda (cursor),y
            beq end_entry       ; possible match, branch if zero terminator
            cmp input,x 
            bne next_entry        ; no match
            inx
            iny
            bne next_char

        error:
            ; ERROR PANIC
            inc eof
            rts

    next_entry: 
        jsr advance_cursor
        bne match_entry

    not_found:
        lda #'?'
        jsr CHROUT
        ; report not found
        inc eof
        rts

    end_entry:
        lda input,x
        lda input,x
        cmp #33
        bcs next_entry
    found:
        iny 
        stx offset 
        
    @f1:
        jmp (cursor)
        rts 
.endproc ; parse_entry

.proc reset_cursor
    lda dbottom
    sta cursor
    lda dbottom+1
    sta cursor+1
    rts 
.endproc ; reset_cursor

.proc advance_cursor ; leaves high byte of cursor address in a
    ldy #3
    lda (cursor),y
    tax 
    iny 
    lda (cursor),y
    
    stx cursor
    sta cursor+1
    rts
.endproc ; advance_cursor

main:
    jsr getinput
    jsr CRLF
    jsr interpret
    jsr CRLF
    jmp main
    rts

debug:
    lda cursor+1
    jsr WRTWO
    lda cursor
    jsr WRTWO
    rts

getinput:
        ldx #0
        stx offset
SMOVE:  jsr CHRIN
        sta BUF,X
        inx
        CPX #ENDIN-BUF   ; error if buffer is full
        BCS ierror
        cmp #13             ; keep reading until CR
        bne SMOVE
        LDA #0              ; null-terminate input buffer
        STA BUF-1,X         ; (replacing the CR)
        rts

ierror:
    LDY #MSG1-MSGBAS
    JSR SNDMSG    
    rts

banner:
    LDY #MSG2-MSGBAS
    JSR SNDMSG    
    rts




.include "utils.s"
; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE "5TH 0.1",13+$80
MSG1:   .BYTE "INPUT ERROR ",13+$80
MSG2:   .BYTE "****",13+$80


offset:
    .byte 0

dbottom:
    .word _dbottom

eof:
    .byte 0

hex_result: .word 0

SP: .byte 0
STACK: .res 256
