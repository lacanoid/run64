.include "../defs64.inc"
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

.include "vocab/index.s"

.proc print_dec ; expects SP in x
    lda STACK-2,x
    sta X0 
    lda STACK-1,x
    sta X1  

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
      ROL     X0                  ; shift quotient bit into X while shifting out next dividend bit into A
      ROL     X1
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
    X0: .byte 0
    X1: .byte 0
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
    lda f_quit
    beq main
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




.include "../utils.s"
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

f_quit:
    .byte 0

hex_result: .word 0

SP: .byte 0
STACK: .res 256
