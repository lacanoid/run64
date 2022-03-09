; -----------------------------------------------------------------------------
; variables

SAVX:   .res 1             ; 1 byte temp storage, often to save X register
SAVY:   .res 1             ; 1 byte temp storage, often to save Y register
CHRPNT: .res 1             ; current position in input buffer

; -----------------------------------------------------------------------------
; print address
SHOWAD: LDA TMP2
        LDX TMP2+1

WRADDR: PHA                 ; save low byte
        TXA                 ; put high byte in A
        JSR WRTWO           ; output high byte
        PLA                 ; restore low byte

WRBYTE: JSR WRTWO           ; output byte in A

SPACE:  LDA #$20            ; output space
        BNE FLIP

CHOUT:  CMP #$0D            ; output char with special handling of CR
        BNE FLIP
CRLF:   LDA #$0D            ; load CR in A
        BIT $13             ; check default channel
        BPL FLIP            ; if high bit is clear output CR only
        JSR CHROUT          ; otherwise output CR+LF
        LDA #$0A            ; output LF
FLIP:   JMP CHROUT

FRESH:  JSR CRLF            ; output CR
        LDA #$20            ; load space in A
        JSR CHROUT
        JMP SNCLR

; -----------------------------------------------------------------------------
; output two hex digits for byte
WRTWO:  STX SAVX            ; save X
        JSR ASCTWO          ; get hex chars for byte in X (lower) and A (upper)
        JSR CHROUT          ; output upper nybble
        TXA                 ; transfer lower to A
        LDX SAVX            ; restore X
        JMP CHROUT          ; output lower nybble

; -----------------------------------------------------------------------------
; convert byte in A to hex digits
ASCTWO: PHA                 ; save byte
        JSR ASCII           ; do low nybble
        TAX                 ; save in X
        PLA                 ; restore byte
        LSR A               ; shift upper nybble down
        LSR A
        LSR A
        LSR A

; convert low nybble in A to hex digit
ASCII:  AND #$0F            ; clear upper nibble
        CMP #$0A            ; if less than A, skip next step
        BCC ASC1
        ADC #6              ; skip ascii chars between 9 and A
ASC1:   ADC #$30            ; add ascii char 0 to value
        RTS

; -----------------------------------------------------------------------------
; get prev char from input buffer
GOTCHR: DEC CHRPNT

; get next char from input buffer
GETCHR: STX SAVX
        LDX CHRPNT          ; get pointer to next char
        LDA BUF,X        ; load next char in A
        BEQ NOCHAR          ; null, :, or ? signal end of buffer
        CMP #':'        
        BEQ NOCHAR
        CMP #'?'
NOCHAR: PHP
        INC CHRPNT          ; next char
        LDX SAVX
        PLP                 ; Z flag will signal last character
        RTS

; -----------------------------------------------------------------------------
; parse optionally quoted filename from command line

GETFNADR:
        lda #$20
        sta GETFNTERM
GETFNADR1:
        JSR GETCHR
        BEQ GETFNADR2   ; end of string
        CMP #$20        ; skip leading spaces
        BEQ GETFNADR1
        CMP #'"'
        BNE GETFNADR2   ; not a quoted string
        sta GETFNTERM
        JSR GETCHR      ; skip quote
GETFNADR2:              ; get up to the terminator char
        dec CHRPNT
        lda #<BUF
        add CHRPNT
        tax
        lda #>BUF
        adc #0
        tay
        stxy FNADR
        inc CHRPNT

        ldy #0              ; compute file name length
@loop:  lda (FNADR),y
        beq GETFNADRE
        CMP GETFNTERM       ; compare with terminator
        BEQ GETFNADRE
        iny
        bpl @loop
GETFNADRE:
        tya
        clc
        adc CHRPNT
        sta CHRPNT

        tya
        ldxy FNADR
        cmp #0
        rts
GETFNTERM:
        .byte 0

; -----------------------------------------------------------------------------
; print and clear routines
CLINE:  JSR CRLF            ; send CR+LF
        JMP SNCLR           ; clear line
SNDCLR: JSR SNDMSG
SNCLR:  LDY #$28            ; loop 40 times
SNCLP:  LDA #$20            ; output space character
        JSR CHROUT
        LDA #$14            ; output delete character
        JSR CHROUT
        DEY
        BNE SNCLP
        RTS

; -----------------------------------------------------------------------------
; display message from table
SNDMSG: LDA MSGBAS,Y        ; Y contains offset in msg table
        PHP
        AND #$7F            ; strip high bit before output
        JSR CHOUT
        INY
        PLP
        BPL SNDMSG          ; loop until high bit is set
        RTS
