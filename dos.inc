; -----------------------------------------------------------------------------
; display disk error
INSTAT: 
        JSR CLRCHN
        lda #0
        sta STATUS
        JSR UNLSN           ; command device to unlisten
INSTAT1:LDA FA              ; load device address
        JSR TALK            ; command device to talk
        LDA #$6F            ; secondary address 15 (only low nybble used)
        JSR TKSA
RDSTAT: JSR ACPTR           ; read byte from serial bus
        JSR CHROUT          ; print it
        CMP #$0D            ; if the byte is CR, exit loop
        BEQ DEXIT
        LDA STATUS           ; check status
        AND #$BF            ; ignore EOI bit
        BEQ RDSTAT          ; if no errors, read next byte
DEXIT:  JSR UNTLK           ; command device to stop talking
        RTS


; get directory
DIRECT: LDA FA              ; load device address
        JSR LISTEN          ; command device to listen
        LDA #$F0            ; secondary address 0 (only low nybble used)
        JSR SECOND

        LDX FNLEN
        BEQ DIR3
        LDY #0
DIR2:   LDA (FNADR),Y       ; get next character from buffer
        BEQ DIR3            ; break if it's null
        JSR CIOUT           ; send character to device
        INY                 ; increment characer index
        DEX
DIR3:   JSR UNLSN           ; command device to unlisten
        LDA FA              ; load device address
        PHA                 ; save on stack
        JSR TALK            ; command device to talk
        LDA #$60            ; secondary address 0 (only low nybble used)
        JSR TKSA
        LDY #3              ; read 3 16-bit values from device
DIRLIN: STY STORE           ; ignore the first 2; 3rd is file size
DLINK:  JSR ACPTR           ; read low byte from device
        STA T1              ; store it
        LDA STATUS          ; check status
        BNE DREXIT          ; exit if error or eof occurred
        JSR ACPTR           ; read high byte from device
        STA T2              ; store it
        LDA STATUS          ; check status
        BNE DREXIT          ; exit if error or eof cocurred
        DEC STORE           ; decrement byte count
        BNE DLINK           ; loop if bytes remain

        LDX T1
        LDA T2
        JSR LINPRT

        LDA #' '            ; output space
        JSR CHROUT
DNAME:  JSR ACPTR           ; get a filename character from the device
        BEQ DMORE           ; if it's null, break out of loop
        LDX STATUS          ; check for errors or eof
        BNE DREXIT          ; if found exit early
        JSR CHROUT          ; output character
        CLC
        BCC DNAME           ; unconditional branch to read next char
DMORE:  LDA #13
        JSR CHROUT
        JSR STOP            ; check for stop key
        BEQ DREXIT          ; exit early if pressed
        JSR GETIN           ; pause if a key was pressed
        BEQ NOPAWS
PAWS:   JSR GETIN           ; wait until another key is pressed
        BEQ PAWS            
NOPAWS: LDY #2
        BNE DIRLIN          ; unconditional branch to read next file
DREXIT: JSR UNTLK           ; command device to untalk
        PLA                 ; restore accumulator
        JSR LISTEN          ; command device to listen
        LDA #$E0            ; secondary address 0 (only low nybble is used)
        JSR SECOND
        JSR UNLSN           ; command device to unlisten
        RTS

STORE:
        .byte 1

