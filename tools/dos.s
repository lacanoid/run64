; -----------------------------------------------------------------------------
; load, save, or verify [LSV]
LD:    LDY #1              ; default to reading from tape, device #1
        STY FA
        STY SA              ; default to secondary address #1
        DEY
        STY FNLEN           ; start with an empty filename
        STY STATUS           ; clear status
        LDA #>STAGE         ; set filename pointer to staging buffer
        STA FNADR+1
        LDA #<STAGE
        STA FNADR
L1:     JSR GETCHR          ; get a character
        BEQ LSHORT          ; no filename given, try load or verify from tape
        CMP #$20            ; skip leading spaces
        BEQ L1
        CMP #$22            ; error if filename doesn't start with a quote
        BNE LERROR
        LDX CHRPNT          ; load current char pointer into index reg
L3:     LDA BUF,X        ; load current char from buffer to accumulator
        BEQ LSHORT          ; no filename given, try load or verify from tape
        INX                 ; next char
        CMP #$22            ; is it a quote?
        BEQ L8              ; if so, we've reached the end of the filename
        STA (FNADR),Y       ; if not, save character in filename buffer
        INC FNLEN           ; increment filename length
        INY 
        CPY #ESTAGE-STAGE   ; check whether buffer is full
        BCC L3              ; if not, get another character
LERROR: JMP ERROR           ; if so, handle error
L8:     STX CHRPNT          ; set character pointer to the current index
        JSR GETCHR          ; eat separator between filename and device #
        BEQ LSHORT          ; no separator, try to load or verify from tape
        JSR GETPAR          ; get device number
        BCS LSHORT          ; no device # given, try load or verify from tape
        LDA TMP0            ; set device number for kernal routines
        STA FA
        JSR GETPAR          ; get start address for load or save in TMP0
        BCS LSHORT          ; no start address, try to load or verify
        JSR COPY12          ; transfer start address to TMP2
        JSR GETPAR          ; get end address for save in TMP0
        BCS LDADDR          ; no end address, try to load to given start addr
        JSR CRLF            ; new line
        LDX TMP0            ; put low byte of end address in X
        LDY TMP0+1          ; put high byte of end address in Y
        LDA SAVY            ; confirm that we're doing a save
        CMP #'s'
        BNE LERROR          ; if not, error due to too many params
        LDA #0
        STA SA            ; set secondary address to 0
        LDA #TMP2           ; put addr of zero-page pointer to data in A
        JSR SAVE            ; call kernal save routine
LSVXIT: JMP STRT            ; back to mainloop
LSHORT: LDA SAVY            ; check which command we received
        CMP #'v'
        BEQ LOADIT          ; we're doing a verify so don't set A to 0
        CMP #'l'
        BNE LERROR          ; error due to not enough params for save
        LDA #0              ; 0 in A signals load, anything else is verify
LOADIT: JSR LOAD            ; call kernal load routine
        LDA STATUS           ; get i/o status
        AND #$10            ; check bit 5 for checksum error
        BEQ LSVXIT          ; if no error go back to mainloop
        LDA SAVY            ; ?? not sure what these two lines are for...
        BEQ LERROR          ; ?? SAVY will never be 0, so why check?
        LDY #MSG6-MSGBAS    ; display "ERROR" if checksum didn't match
        JSR SNDMSG
        JMP STRT            ; back to mainloop
LDADDR: LDX TMP2            ; load address low byte in X
        LDY TMP2+1          ; load address high byte in Y
        LDA #0              ; 0 in A signals load
        STA SA              ; secondary addr 0 means load to addr in X and Y
        BEQ LSHORT          ; execute load

; -----------------------------------------------------------------------------
; disk status/command [@]
DSTAT:  
;        JSR GETPAR
;        BNE CHGDEV          ; if device address was given, use it
        LDX FA              ; otherwise, default to 8
;        .BYTE $2C           ; absolute BIT opcode consumes next word (LDX TMP0)
;CHGDEV: LDX TMP0            ; load device address from parameter
        CPX #4              ; make sure device address is in range 4-31
        BCC IOERR
        CPX #32
        BCS IOERR
        STX FA
        STX TMP0
        LDA #0              ; clear status
        STA STATUS
        STA FNLEN           ; empty filename
        JSR GETCHR          ; get next character
        BEQ INSTAT1         ; null, display status
        DEC CHRPNT          ; back up 1 char
        CMP #'$'            ; $, display directory
        BEQ DIRECT
        LDA TMP0            ; command specified device to listen
        JSR LISTEN
        LDA #$6F            ; secondary address 15 (only low nybble used)
        JSR SECOND

; send command to device
DCOMD:  LDX CHRPNT          ; get next character from buffer
        INC CHRPNT
        LDA BUF,X
        BEQ INSTAT          ; break out of loop if it's null
        JSR CIOUT           ; otherwise output it to the serial bus
        BCC DCOMD           ; unconditional loop:CIOUT clears carry before RTS

; get device status
INSTAT: JSR UNLSN           ; command device to unlisten
INSTAT1:JSR CRLF            ; new line
        LDA TMP0            ; load device address
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
        JMP STRT            ; back to mainloop
IOERR:  JMP ERROR           ; handle error

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
        JMP STRT            ; back to mainloop
