
; -----------------------------------------------------------------------------
; display disk error
.proc DOS_INSTAT
        JSR CLRCHN
        lda #0
        sta STATUS
        JSR UNLSN           ; command device to unlisten
    INSTAT1:                    ; new line
        LDA FA              ; load device address
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
.endproc

.proc DIRECT 
    ; get directory
    DIRECT: LDA TMP0            ; load device address
            JSR LISTEN          ; command device to listen
            LDA #$F0            ; secondary address 0 (only low nybble used)
            JSR SECOND
            LDX CHRPNT          ; get index of next character
    DIR2:   LDA BUF,X           ; get next character from buffer
            BEQ DIR3            ; break if it's null
            JSR CIOUT           ; send character to device
            INX                 ; increment characer index
            BNE DIR2            ; loop if it hasn't wrapped to zero
    DIR3:   JSR UNLSN           ; command device to unlisten
            JSR CRLF            ; new line
            LDA TMP0            ; load device address
            PHA                 ; save on stack
            JSR TALK            ; command device to talk
            LDA #$60            ; secondary address 0 (only low nybble used)
            JSR TKSA
            LDY #3              ; read 3 16-bit values from device
    DIRLIN: STY STORE           ; ignore the first 2; 3rd is file size
    DLINK:  JSR ACPTR           ; read low byte from device
            STA TMP0            ; store it
            LDA STATUS           ; check status
            BNE DREXIT          ; exit if error or eof occurred
            JSR ACPTR           ; read high byte from device
            STA TMP0+1          ; store it
            LDA STATUS           ; check status
            BNE DREXIT          ; exit if error or eof cocurred
            DEC STORE           ; decrement byte count
            BNE DLINK           ; loop if bytes remain
            JSR CVTDEC          ; convert last 16-bit value to decimal
            LDA #0              ; clear digit count
            LDX #6              ; max 6 digits
            LDY #3              ; 3 bits per digit
            JSR NMPRNT          ; output number
            LDA #' '            ; output space
            JSR CHROUT
    DNAME:  JSR ACPTR           ; get a filename character from the device
            BEQ DMORE           ; if it's null, break out of loop
            LDX STATUS           ; check for errors or eof
            BNE DREXIT          ; if found exit early
            JSR CHROUT          ; output character
            CLC
            BCC DNAME           ; unconditional branch to read next char
    DMORE:  JSR CRLF
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
            rts            ; back to mainloop
.endproc