; -----------------------------------------------------------------------------
; main loop
STRT:   jsr CRLF

        ; print current drive and prompt
        lda FA
        jsr WRTWO
;        lda STATUS
;        jsr WRTWO
        msg prompt

        ; read one line of input into BUF
        ldx #0
        
SMOVE:  stx CHRPNT
        jsr CHRIN
        tay
        lda STATUS
        beq @ok1
        jsr CLRCHN
        lda #0
        sta STATUS
@ok1:   ldx CHRPNT
        tya
        sta BUF,X
        inx
        CPX #ENDIN-BUF   ; error if buffer is full
        BCS ERROR
        cmp #10          ; convert lf to cr
        bne @sm1
        lda #13
@sm1:   cmp #13             ; keep reading until CR
        bne SMOVE
        LDA #0              ; null-terminate input buffer
        STA BUF-1,X         ; (replacing the CR)

        ; execute BUF
STRT2: 
        LDA #0
        STA CHRPNT
        stx COUNT
        dec COUNT
        beq STRT            ; repeat if buffer is empty

ST1:    JSR GETCHR          ; get a character from the buffer
        BEQ STRT            ; start over if buffer is empty
        CMP #$20            ; skip leading spaces
        BEQ ST1

S0:     LDX #KEYTOP-KEYW    ; loop through valid command characters
S1:     CMP KEYW,X          ; see if input character matches
        BEQ S2              ; command matched, dispatch it
        DEX                 ; no match, check next command
        BPL S1              ; keep trying until we've checked them all
                            ; then fall through to error handler
; -----------------------------------------------------------------------------
; handle error
ERROR:
        LDY #MSG3-MSGBAS    ; display "?" to indicate error and go to new line
        JSR SNDMSG
        JSR CLRCHN
        JMP STRT            ; back to main loop

; -----------------------------------------------------------------------------
; dispatch command
S2:
        CPX #KEYTOP-KEYW-3  ; last 3 commands in table are load/save/validate
        BCS LSV             ;   which are handled by the same subroutine
        CPX #KEYTOP-KEYW-7  ; next 4 commands are base conversions
        BCS CNVLNK          ;   which are handled by the same subroutine
        TXA                 ; remaining commands dispatch through vector table
        ASL A               ; multiply index of command by 2
        TAX                 ;   since table contains 2-byte addresses
        LDA KADDR+1,X       ; push address from vector table onto stack
        PHA                 ;   so that the RTS from GETPAR will jump there
        LDA KADDR,X
        PHA
;        JMP GETPAR         ; get the first parameter for the command
        RTS
LSV:   STA SAVY             ; handle load/save/validate
        JMP LD
CNVLNK: JMP CONVRT          ; handle base conversion

; -----------------------------------------------------------------------------
; read parameters
RDPAR:  DEC CHRPNT          ; back up one char
GETPAR: JSR RDVAL           ; read the value
        BCS GTERR           ; carry set indicates error
        JSR GOTCHR          ; check previous character
        BNE CKTERM          ; if it's not null, check if it's a valid separator
        DEC CHRPNT          ; back up one char
        LDA DIGCNT          ; get number of digits read
        BNE GETGOT          ; found some digits
        BEQ GTNIL           ; didn't find any digits
CKTERM: CMP #$20            ; space or comma are valid separators
        BEQ GETGOT          ; anything else is an error
        CMP #','
        BEQ GETGOT
GTERR:  PLA                 ; encountered error
        PLA                 ; get rid of command vector pushed on stack
        JMP ERROR           ; handle error
GTNIL:  SEC                 ; set carry to indicate no parameter found
        .BYTE $24           ; BIT ZP opcode consumes next byte (CLC)
GETGOT: CLC                 ; clear carry to indicate paremeter returned
        LDA DIGCNT          ; return number of digits in A
        RTS                 ; return to address pushed from vector table

; -----------------------------------------------------------------------------
; read a value in the specified base
RDVAL:  LDA #0              ; clear temp
        STA TMP0
        STA TMP0+1
        STA DIGCNT          ; clear digit counter
        TXA                 ; save X and Y
        PHA
        TYA
        PHA
RDVMOR: JSR GETCHR          ; get next character from input buffer
        BEQ RDNILK          ; null at end of buffer
        CMP #$20            ; skip spaces
        BEQ RDVMOR
        LDX #3              ; check numeric base [$+&%]
GNMODE: CMP HIKEY,X
        BEQ GOTMOD          ; got a match, set up base
        DEX
        BPL GNMODE          ; check next base
        INX                 ; default to hex
        DEC CHRPNT          ; back up one character
GOTMOD: LDY MODTAB,X        ; get base value
        LDA LENTAB,X        ; get bits per digit
        STA NUMBIT          ; store bits per digit 
NUDIG:  JSR GETCHR          ; get next char in A
RDNILK: BEQ RDNIL           ; end of number if no more characters
        SEC
        SBC #$30            ; subtract ascii value of 0 to get numeric value
        BCC RDNIL           ; end of number if character was less than 0
        CMP #$0A
        BCC DIGMOR          ; not a hex digit if less than A
        SBC #$07            ; 7 chars between ascii 9 and A, so subtract 7
        CMP #$10            ; end of number if char is greater than F
        BCS RDNIL
DIGMOR: STA INDIG           ; store the digit
        CPY INDIG           ; compare base with the digit
        BCC RDERR           ; error if the digit >= the base
        BEQ RDERR
        INC DIGCNT          ; increment the number of digits
        CPY #10
        BNE NODECM          ; skip the next part if not using base 10
        LDX #1
DECLP1: LDA TMP0,X          ; stash the previous 16-bit value for later use
        STA STASH,X
        DEX
        BPL DECLP1
NODECM: LDX NUMBIT          ; number of bits to shift
TIMES2: ASL TMP0            ; shift 16-bit value by specified number of bits
        ROL TMP0+1
        BCS RDERR           ; error if we overflowed 16 bits
        DEX
        BNE TIMES2          ; shift remaining bits
        CPY #10
        BNE NODEC2          ; skip the next part if not using base 10
        ASL STASH           ; shift the previous 16-bit value one bit left
        ROL STASH+1
        BCS RDERR           ; error if we overflowed 16 bits
        LDA STASH           ; add shifted previous value to current value
        ADC TMP0
        STA TMP0
        LDA STASH+1
        ADC TMP0+1
        STA TMP0+1
        BCS RDERR           ; error if we overflowed 16 bits
NODEC2: CLC 
        LDA INDIG           ; load current digit
        ADC TMP0            ; add current digit to low byte
        STA TMP0            ; and store result back in low byte
        TXA                 ; A=0
        ADC TMP0+1          ; add carry to high byte
        STA TMP0+1          ; and store result back in high byte
        BCC NUDIG           ; get next digit if we didn't overflow
RDERR:  SEC                 ; set carry to indicate error
        .BYTE $24           ; BIT ZP opcode consumes next byte (CLC)
RDNIL:  CLC                 ; clear carry to indicate success
        STY NUMBIT          ; save base of number
        PLA                 ; restore X and Y
        TAY
        PLA
        TAX
        LDA DIGCNT          ; return number of digits in A
        RTS

; -----------------------------------------------------------------------------
; copy TMP0 to TMP2
COPY12: LDA TMP0            ; low byte
        STA TMP2
        LDA TMP0+1          ; high byte
        STA TMP2+1
        RTS

; -----------------------------------------------------------------------------
; copy TMP0 to PC
COPY1P: BCS CPY1PX          ; do nothing if parameter is empty
        LDA TMP0            ; copy low byte
        LDY TMP0+1          ; copy high byte
        STA PCL
        STY PCH
CPY1PX: RTS 

; -----------------------------------------------------------------------------
; convert base [$+&%]
CONVRT: JSR RDPAR           ; read a parameter
CONVRT1:
        JSR FRESH           ; output character
        LDA #'"'            
        JSR CHROUT
        LDA TMP0            
        JSR CHROUT
        LDA TMP1            
        JSR CHROUT
        LDA #'"'            
        JSR CHROUT

        JSR FRESH           ; next line and clear
        LDA #'$'            ; output $ sigil for hex
        JSR CHROUT
        LDA TMP0            ; load the 16-bit value entered
        LDX TMP0+1
        JSR WRADDR          ; print it in 4 hex digits
        JSR FRESH
        LDA #'+'            ; output + sigil for decimal
        JSR CHROUT
        JSR CVTDEC          ; convert to BCD using hardware mode
        LDA #0              ; clear digit counter
        LDX #6              ; max digits + 1
        LDY #3              ; bits per digit - 1
        JSR NMPRNT          ; print result without leading zeros
        JSR FRESH           ; next line and clear
        LDA #'&'            ; print & sigil for octal
        JSR CHROUT
        LDA #0              ; clear digit counter
        LDX #8              ; max digits + 1
        LDY #2              ; bits per digit - 1
        JSR PRINUM          ; output number
        JSR FRESH           ; next line and clear
        LDA #'%'            ; print % sigil for binary
        JSR CHROUT
        LDA #0              ; clear digit counter
        LDX #$18            ; max digits + 1
        LDY #0              ; bits per digit - 1
        JSR PRINUM          ; output number

        JSR FRESH           ; next line and clear

        LDA #'#'            ; print % sigil for binary
        JSR CHROUT
        lda TMP0            ; 1st charaster
        and #$1F
        ora #$40
        jsr CHROUT

        lda TMP1            ; 2nd character
        and #$03
        sta T1

        lda TMP0
        asl
        rol T1
        asl
        rol T1
        asl
        rol T1
        lda T1

        ldx TMP1          ;
        cpx #$c6
        beq @cvt3         ; it is a number

        ora #$40
        jsr CHROUT

        lda TMP1            ; 3rd character
        bmi @cvt5
@cvt4:       ; it is a letter
        lsr
        lsr
        and #$1f
        ora #$40
        bne @cvt9           ; allways
@cvt5:  ; it is a digit
        lsr
        lsr
@cvt3:
        and #$0f
        ora #$30
@cvt9:
        jsr CHROUT
        JMP STRT            ; back to mainloop

; -----------------------------------------------------------------------------
; convert binary to BCD

CVTDEC: JSR COPY12          ; copy value from TMP0 to TMP2
        LDA #0
        LDX #2              ; clear 3 bytes in work buffer
DECML1: STA U0AA0,X
        DEX
        BPL DECML1
        LDY #16             ; 16 bits in input
        PHP                 ; save status register
        SEI                 ; make sure no interrupts occur with BCD enabled
        SED
DECML2: ASL TMP2            ; rotate bytes out of input low byte
        ROL TMP2+1          ; .. into high byte and carry bit
        LDX #2              ; process 3 bytes
DECDBL: LDA U0AA0,X         ; load current value of byte
        ADC U0AA0,X         ; add it to itself plus the carry bit
        STA U0AA0,X         ; store it back in the same location
        DEX                 ; decrement byte counter
        BPL DECDBL          ; loop until all bytes processed
        DEY                 ; decrement bit counter
        BNE DECML2          ; loop until all bits processed
        PLP                 ; restore processor status
        RTS

; load the input value and fall through to print it
PRINUM: PHA                 ; save accumulator
        LDA TMP0            ; copy input low byte to work buffer
        STA U0AA0+2
        LDA TMP0+1          ; copy input high byte to work buffer
        STA U0AA0+1
        LDA #0              ; clear overflow byte in work buffer
        STA U0AA0
        PLA                 ; restore accumulator

; print number in specified base without leading zeros
NMPRNT: STA DIGCNT          ; number of digits in accumulator
        STY NUMBIT          ; bits per digit passed in Y register
DIGOUT: LDY NUMBIT          ; get bits to process
        LDA #0              ; clear accumulator
ROLBIT: ASL U0AA0+2         ; shift bits out of low byte
        ROL U0AA0+1         ; ... into high byte
        ROL U0AA0           ; ... into overflow byte
        ROL A               ; ... into accumulator
        DEY                 ; decrement bit counter
        BPL ROLBIT          ; loop until all bits processed
        TAY                 ; check whether accumulator is 0
        BNE NZERO           ; if not, print it
        CPX #1              ; have we output the max number of digits?
        BEQ NZERO           ; if not, print it
        LDY DIGCNT          ; how many digits have we output?
        BEQ ZERSUP          ; skip output if digit is 0
NZERO:  INC DIGCNT          ; increment digit counter
        ORA #$30            ; add numeric value to ascii '0' to get ascii char
        JSR CHROUT          ; output character
ZERSUP: DEX                 ; decrement number of leading zeros
        BNE DIGOUT          ; next digit
        RTS
