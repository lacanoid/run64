; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

.import __TBUFFR_SIZE__, __TBUFFR_LOAD__, __TBUFFR_RUN__
.import __CARTHDR_SIZE__, __CARTHDR_LOAD__, __CARTHDR_RUN__

.macro msg addr 
       leaxy addr 
       jsr msgout
.endmacro  

.macro chrout c
       lda #c 
       jsr CHROUT
.endmacro

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.
resultRegister = $d7ff

; -----------------------------------------------------------------------------
; initial entry point
SUPER:  LDY #MSG4-MSGBAS    ; display "..SYS "
        JSR SNDMSG
        LDA SUPAD           ; store entry point address in tmp0
        STA TMP0
        LDA SUPAD+1
        STA TMP0+1
        JSR CVTDEC          ; convert address to decimal
        LDA #0
        LDX #6
        LDY #3
        JSR NMPRNT          ; print entry point address
;        JSR CRLF
        LDA LINKAD          ; set BRK vector
        STA CBINV
        LDA LINKAD+1
        STA CBINV+1

        LDA #$80            ; disable kernel control messages
        JSR SETMSG          ; and enable error messages

        ldxy IERROR
        stxy ON_ERR_SAV

        BRK

; -----------------------------------------------------------------------------
; BRK handler
BREAK:  LDX #$05            ; pull registers off the stack
BSTACK: PLA                 ; order:Y,X,A,SR,PCL,PCH
        STA PCH,X           ; store in memory
        DEX 
        BPL BSTACK
        CLD                 ; disable bcd mode
        TSX                 ; store stack pointer in memory 
        STX SP
        CLI                 ; enable interupts

        LDY #MSG2-MSGBAS    ; display "?" to indicate error and go to new line
        JSR SNDMSG

        lda SP
        jsr hexout
        jsr SPACE
        ldx PCL
        ldy PCH
        jsr hexoutxy
        jsr SPACE
        lda ACC
        jsr hexout
        jsr CRLF
; -----------------------------------------------------------------------------
; kmon init
kmon:
        LDY #MSG0-MSGBAS    ; display "?" to indicate error and go to new line
        JSR SNDMSG

; -----------------------------------------------------------------------------
; main loop
STRT:   jsr CRLF

        ; print current drive and prompt
        lda FA
        jsr hexout
        msg prompt

        ; read one line of input into BUF
        ldx #0
        stx CHRPNT
SMOVE:  jsr CHRIN
        sta BUF,X
        inx
        CPX #ENDIN-BUF   ; error if buffer is full
        BCS ERROR
        cmp #13             ; keep reading until CR
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
ERROR: LDY #MSG3-MSGBAS    ; display "?" to indicate error and go to new line
        JSR SNDMSG
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
;        JMP GETPAR          ; get the first parameter for the command
        RTS
LSV:   STA SAVY            ; handle load/save/validate
        JMP LD
CNVLNK: JMP CONVRT          ; handle base conversion

; -----------------------------------------------------------------------------
; exit monitor [X]
EXIT:   
        ldxy ON_ERR_SAV
        stxy IERROR
        JMP ($A002)         ; jump to warm-start vector to reinitialize BASIC


; -----------------------------------------------------------------------------
; variables

SAVX:   .res 1             ; 1 byte temp storage, often to save X register
SAVY:   .res 1             ; 1 byte temp storage, often to save Y register
DIGCNT: .res 1             ; digit count
INDIG:  .res 1             ; numeric value of single digit
NUMBIT: .res 1             ; numeric base of input
STASH:  .res 2             ; 2-byte temp storage
U0AA0:  .res 10            ; work buffer
U0AAE   =*                  ; end of work buffer
STAGE:  .res 30            ; staging buffer for filename, search, etc.
ESTAGE  =*                  ; end of staging buffer
STORE:  .res 2             ; 2-byte temp storage
CHRPNT: .res 1             ; current position in input buffer

PCH:    .res 1             ; program counter high byte
PCL:    .res 1             ; program counter low byte
SR:     .res 1             ; status register
ACC:    .res 1             ; accumulator
XR:     .res 1             ; X register
YR:     .res 1             ; Y register
SP:     .res 1             ; stack pointer


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
        CMP #'S'
        BNE LERROR          ; if not, error due to too many params
        LDA #0
        STA SA            ; set secondary address to 0
        LDA #TMP2           ; put addr of zero-page pointer to data in A
        JSR SAVE            ; call kernal save routine
LSVXIT: JMP STRT            ; back to mainloop
LSHORT: LDA SAVY            ; check which command we received
        CMP #'V'
        BEQ LOADIT          ; we're doing a verify so don't set A to 0
        CMP #'L'
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
        STA SA            ; secondary addr 0 means load to addr in X and Y
        BEQ LSHORT          ; execute load

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
; new [N]
CMDNEW: JSR GETPAR
        LDX SP              ; load stack pointer from memory
        TXS                 ; save in SP register
        JSR COPY1P          ; copy provided address to PC
        LDA PCH             ; push PC high byte on stack
        STA TXTTAB+1
        LDA PCL             ; push PC low byte on stack
        STA TXTTAB
        JSR SCRTCH
        JMP STRT

; -----------------------------------------------------------------------------
; alter memory [>]
ALTM:   BCS ALTMX           ; exit if no parameter provided
        JSR COPY12          ; copy parameter to start address
        LDY #0
ALTM1:  JSR GETPAR          ; get value for next byte of memory
        BCS ALTMX           ; if none given, exit early
        LDA TMP0            ; poke value into memory at start address + Y
        STA (TMP2),Y
        INY                 ; next byte
        CPY #8              ; have we read 8 bytes yet?
        BCC ALTM1           ; if not, read the next one
ALTMX:  LDA #$91            ; move cursor up
        JSR CHROUT
        JSR DISPMEM         ; re-display line to make ascii match hex
        JMP STRT            ; back to main loop

; -----------------------------------------------------------------------------
; goto (run) [G]
GOTO:   LDX SP              ; load stack pointer from memory
        TXS                 ; save in SP register
GOTO2:  JSR COPY1P          ; copy provided address to PC
        SEI                 ; disable interrupts
        LDA PCH             ; push PC high byte on stack
        PHA
        LDA PCL             ; push PC low byte on stack
        PHA
        LDA SR              ; push status byte on stack
        PHA
        LDA ACC             ; load accumulator from memory
        LDX XR              ; load X from memory
        LDY YR              ; load Y from memory
        RTI                 ; return from interrupt (pops PC and SR)

; jump to subroutine [J]
JSUB:   LDX SP              ; load stack pointer from memory
        TXS                 ; save value in SP register
        JSR GOTO2           ; same as goto command
        STY YR              ; save Y to memory
        STX XR              ; save X to memory
        STA ACC             ; save accumulator to memory
        PHP                 ; push processor status on stack
        PLA                 ; pull processor status into A
        STA SR              ; save processor status to memory
;        JMP DSPLYR          ; display registers
        JMP STRT

; -----------------------------------------------------------------------------
; display 8 bytes of memory
DISPMEM:JSR CRLF            ; new line
        LDA #'>'            ; prefix > so memory can be edited in place
        JSR CHROUT
        JSR SHOWAD          ; show address of first byte on line
        LDY #0
        BEQ DMEMGO          ; SHOWAD already printed a space after the address
DMEMLP: JSR SPACE           ; print space between bytes
DMEMGO: LDA (TMP2),Y        ; load byte from start address + Y
        JSR WRTWO           ; output hex digits for byte
        INY                 ; next byte
        CPY #8              ; have we output 8 bytes yet?
        BCC DMEMLP          ; if not, output next byte
        LDY #MSG5-MSGBAS    ; if so, output : and turn on reverse video
        JSR SNDMSG          ;   before displaying ascii representation
        LDY #0              ; back to first byte in line
DCHAR:  LDA (TMP2),Y        ; load byte at start address + Y
        TAX                 ; stash in X
        AND #$BF            ; clear 6th bit
        CMP #$22            ; is it a quote (")?
        BEQ DDOT            ; if so, print . instead
        TXA                 ; if not, restore character
        AND #$7F            ; clear top bit
        CMP #$20            ; is it a printable character (>= $20)?
        TXA                 ; restore character
        BCS DCHROK          ; if printable, output character
DDOT:   LDA #$2E            ; if not, output '.' instaed
DCHROK: JSR CHROUT
        INY                 ; next byte
        CPY #8              ; have we output 8 bytes yet?
        BCC DCHAR           ; if not, output next byte
        RTS 

; -----------------------------------------------------------------------------
; convert base [$+&%]
CONVRT: JSR RDPAR           ; read a parameter
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
; -----------------------------------------------------------------------------
; disk status/command [@]
DSTAT:  
        JSR GETPAR
        BNE CHGDEV          ; if device address was given, use it
        LDX FA              ; otherwise, default to 8
        .BYTE $2C           ; absolute BIT opcode consumes next word (LDX TMP0)
CHGDEV: LDX TMP0            ; load device address from parameter
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
DIR2:   LDA BUF,X        ; get next character from buffer
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
DIRLIN: STY STORE           ;   ignore the first 2; 3rd is file size
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

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE 14
        .BYTE "KMON 0.",'6'+$80
MSG1:   .BYTE $0D               ; header for registers
        .BYTE "*ERR",'*'+$80
MSG2:   .BYTE $0D               ; header for registers
        .BYTE "*BRK*",$20+$80
MSG3:   .BYTE $1D,$3F+$80       ; syntax error:move right, display "?"
MSG4:   .byte "..SYS"           ; SYS call to enter monitor
        .BYTE $20+$80
MSG5:   .BYTE $3A,$12+$80       ; ":" then RVS ON for memory ASCII dump
MSG6:   .byte " ERRO"           ; I/O error:display " ERROR"
        .BYTE 'R'+$80
MSG7:   .BYTE $41,$20+$80       ; assemble next instruction:"A " + addr
MSG8:   .byte "  "              ; pad non-existent byte:skip 3 spaces
        .BYTE $20+$80


; -----------------------------------------------------------------------------

prompt:
        .asciiz "!"

;----------------------------------------

cmdold:   lda #1
        tay
        sta (TXTTAB),y
        jsr LINKPRG
cmdold2:  
        ldx EAL
        stx VARTAB
        ldy EAL+1
        sty VARTAB+1
        rts

; ---------------------------------------------------------------

info:

DSPLYM: jsr CRLF
        jsr meminfo
        jsr CRLF
        jsr listvars
        jmp STRT

meminfo:
;        msg msg0
;        sec
;        jsr MEMBOT
;        jsr hexoutxynl

textinfo:
        msg msg1
        ldxy TXTTAB
        jsr hexoutxynl
        msg msg2
        ldxy VARTAB
        jsr hexoutxynl
;        msg msg3
;        ldxy ARYTAB
;        jsr hexoutxynl
        msg msg4
        ldxy STREND
        jsr hexoutxynl
        msg msg5
        ldxy FRETOP
        jsr hexoutxynl
        msg msg6
        ldxy MEMSIZ
        jsr hexoutxynl

;        msg msgN
;        sec
;        jsr MEMTOP
;        jsr hexoutxynl

;        msg msgSAL
;        ldxy SAL
;        jsr hexoutxynl

        msg msgEAL
        ldxy EAL
        jsr hexoutxynl

        msg msgFNADR
        ldxy FNADR
        jsr hexoutxy
        jsr SPACE
        lda FNLEN
        jsr strout

        rts

;msg0:    .asciiz "MEMBOT "
msg1:    .asciiz "TXTTAB "
msg2:    .asciiz "VARTAB "
;msg3:    .asciiz "ARYTAB "
msg4:    .asciiz "STREND "
msg5:    .asciiz "FRETOP "
msg6:    .asciiz "MEMSIZ "
;msgN:    .asciiz "MEMTOP "
;msgSAL:  .asciiz "SAL    "
msgEAL:  .asciiz "EAL    "
msgFNADR:.asciiz "FNADR  "

DSPLYI:jsr CRLF
        jsr basicinfo
        jsr CRLF
        jsr vectorinfo
        jmp STRT

basicinfo:
        msg msgb1
        ldxy IERROR
        jsr hexoutxynl
        msg msgb2
        ldxy IMAIN
        jsr hexoutxynl
        msg msgb3
        ldxy ICRNCH
        jsr hexoutxynl
        msg msgb4
        ldxy IQPLOP
        jsr hexoutxynl
        msg msgb5
        ldxy IGONE
        jsr hexoutxynl
        msg msgb6
        ldxy IEVAL
        jsr hexoutxynl

        rts

msgb1: .asciiz "IERROR "
msgb2: .asciiz "IMAIN  "
msgb3: .asciiz "ICRNCH "
msgb4: .asciiz "IQPLOP "
msgb5: .asciiz "IGONE  "
msgb6: .asciiz "IEVAL  "


vectorinfo:
        msg msgc1
        ldxy CINV
        jsr hexoutxynl
        msg msgc2
        ldxy CBINV
        jsr hexoutxynl
        msg msgc3
        ldxy NMINV
        jsr hexoutxynl
        rts

msgc1: .asciiz "CINV   "
msgc2: .asciiz "CBINV  "
msgc3: .asciiz "MNINV  "


listvars:
        ldxy  VARTAB
        stxy  T1

lvl2:   lda T2   ; at end?
        cmp ARYTAB+1
        bne lvl3
        lda T1
        cmp ARYTAB
lvl3:   bmi lvlgo
        rts

lvlgo:
        ldy #0
        lda (T1),y
        bmi lvnext1 ; it's a number
        iny
        lda (T1),y
        bpl lvnext1 ; not a string

        ldxy  T1
        jsr hexoutxy
        chrout ':'

        ldy #0
        lda (T1),y
        and #$7f
        jsr CHROUT
        iny
        lda (T1),y
        and #$7f
        bne @lvl4
        lda #' '
@lvl4: jsr CHROUT
        chrout ' '
        iny
        lda (T1),y
        sta COUNT
        jsr hexout
        chrout ' '
        iny 
        lda (T1),y
        tax
        iny
        lda (T1),y
        tay
        jsr hexoutxy
        chrout ' '
        lda COUNT
        jsr strout
        jsr CRLF
lvnext1:       
        ; next
        lda T1
        add #7
        sta T1
        bcc lvl2
        inc T2
        bne lvl2
;
msgout: stx T1
         sty T2
         ldy #0
moprint:lda (T1),y
         beq modone
         jsr CHROUT
         iny
         bpl moprint
modone:
         rts

; -----------------------------------------------------------------------------
; print string A = len, XY = addr
strout:
        sta COUNT
        stxy R2D2
        chrout '"'
        ldy #0
@lvl5:
        lda (R2D2),y
        jsr CHROUT
        iny
        cpy COUNT
        bmi @lvl5
        chrout '"'
        rts

hexoutxynl:
        jsr hexoutxy
        jmp CRLF

hexoutxy:
        tya 
        jsr hexout
        txa 
        jsr hexout
        rts
hexout:
        pha
        pha
        lsr
        lsr
        lsr
        lsr
        jsr hexdig
        jsr CHROUT
        pla
        and #$0f
        jsr hexdig
        jsr CHROUT
        pla
        rts
hexdig:
        cmp #$0a
        bcc hdsk1
        adc #$06
hdsk1:  adc #$30
        rts

; -----------------------------------------------------------------------------
; 
ON_ERR_SET:
        ldxy IERROR
        stxy ON_ERR_JMP+1
        ldxy ERRAD
        stxy IERROR
        rts

ON_ERR:
ON_ERR_CLR:
        ldxy ON_ERR_JMP+1
        stxy IERROR

;        LDY #MSG1-MSGBAS    ; display "?" to indicate error and go to new line
;        JSR SNDMSG
        jmp STRT
ON_ERR_JMP:
        jmp $0000
ON_ERR_SAV:
        .word 0

; -----------------------------------------------------------------------------
DSPLYH:
        jsr CRLF
        lda #KEYTOP-KEYW
        leaxy KEYW
        jsr strout
        jsr CRLF
        jmp STRT

; -----------------------------------------------------------------------------
CMDBOOT:
        jsr INSTALL_CARTHDR
        jsr GETFNADR
        beq CMDBOOT1   ; no argsuments
        sta CH_FNLEN
        tax
        ldy #0
@l1:    lda (FNADR),Y
        sta CH_FN,Y
        iny
        dex
        bne @l1
CMDBOOT1:
        jmp ($FFFC)
CMDBOOTX:
        rts
; -----------------------------------------------------------------------------
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
GETFNADR2:
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
        ldxy FNADR
        cmp #0
        rts
GETFNTERM:
        .byte 0

; -----------------------------------------------------------------------------
INSTALL_CARTHDR:
        LDX  #< (__CARTHDR_SIZE__ + 1)
@loop:  LDA __CARTHDR_LOAD__ - 1, X
        STA __CARTHDR_RUN__ - 1, X
        DEX
        BNE @loop
        LDA COLOR
        STA SAVCOLOR+1
        LDA BGCOL0
        STA SAVBGCOL0+1
        LDA EXTCOL
        STA SAVEXTCOL+1
        RTS

INSTALL_TBUFFR:
        LDX  #< (__TBUFFR_SIZE__ + 1)
@loop:  LDA __TBUFFR_LOAD__ - 1, X
        STA __TBUFFR_RUN__ - 1, X
        DEX
        BNE @loop
        RTS
; -----------------------------------------------------------------------------
; load and run a program

CMDRUN:
        jsr INSTALL_TBUFFR
        jsr GETFNADR
        beq CMDRUNLOADED
CMDRUNGO:
        JSR SETNAM

        ; call resident code in TBUFF which does not return on success
        jsr __TBUFFR_RUN__+3
        bcc CMDRUN1   ; no error
        jsr hexout    ; print error code
        lda #'@'
        sta BUF
        lda #0
        sta BUF+1
        JMP STRT2
CMDRUN1:
        rts

; -----------------------------------------------------------------------------
; run already loaded program
CMDRUNLOADED:
        jsr ON_ERR_SET
        jsr CRLF
        jsr LINKPRG
        jsr RUNC
        jsr STXTPT
        jmp NEWSTT
        rts

; -----------------------------------------------------------------------------
CMDLIST:
        jsr ON_ERR_SET
        jsr LINKPRG
        jsr RUNC
        jsr LIST
        rts

; -----------------------------------------------------------------------------
CMDDIR:           ; directory command
        jsr GETPAR
        bcs CMDDI3
        lda TMP0
        sta FA
CMDDI3:
        ldx #0
CMDDI2: lda CMDDI0,X
        sta BUF,X
        bne CMDDI1
        lda FA       ; substitute current device number
        jsr hexdig
        sta BUF+1
;        inx         ; end of command        
        jmp STRT2
CMDDI1: inx
        bpl CMDDI2
        brk
        rts

CMDDI0:.asciiz "@8,$"

; -----------------------------------------------------------------------------
; single-character commands
KEYW:   .byte "BDEGHIJMNRX@>"
HIKEY:  .byte "$+&%LSV"
KEYTOP  =*

; vectors corresponding to commands above
KADDR: .WORD CMDBOOT-1, CMDDIR-1, CMDLIST-1, GOTO-1, DSPLYH-1, DSPLYI-1 
        .WORD JSUB-1, DSPLYM-1, CMDNEW-1, CMDRUN-1, EXIT-1, DSTAT-1, ALTM-1

; -----------------------------------------------------------------------------
MODTAB: .BYTE $10,$0A,$08,02    ; modulo number systems
LENTAB: .BYTE $04,$03,$03,$01   ; bits per digit

ERRAD:  .word ON_ERR            ;
LINKAD: .WORD BREAK             ; address of brk handler
SUPAD:  .WORD SUPER             ; address of entry point
PRGEND:

; -----------------------------------------------------------------------------
; Tape buffer (resident) section
.segment "TBUFFR"
        jmp run_mon
        jmp run_prg
; -----------------------------------------------------------------------------
; display message from table
loadflags:
        .word 0
; run a monitor
run_mon:
        lda TB_FNLEN
        leaxy TB_FN
        JSR SETNAM
        ldy #0
        nop3
; run a different program, must call setnam
run_prg:
        ldy #1
        sty loadflags
        lda #1
        ldx FA
        bne TBINIT1
        ldx #8
TBINIT1:ldy #0
        jsr SETLFS

        lda #0        ; load, not verify
        ldxy TXTTAB
        JSR LOAD
        bcc TBSTART   ; no error

        LDY #MSG2_1-MSGBAS2 
        JSR SNDMSG2
        rts           ; error

        ; start loaded program
TBSTART:
;        stxy EAL
        lda loadflags
        beq TBSTART1
        jsr IERROR_SET    ; set return to us instead of basic
TBSTART1:
        LDA #0            ; disable kernel control messages
        JSR SETMSG        ; and enable error messages

        lda #$0D
        jsr CHROUT
;        LDY #MSG2_0-MSGBAS2    ;
;        JSR SNDMSG2

        ldxy EAL
        stxy VARTAB
        jsr LINKPRG
        jsr RUNC
        jsr STXTPT
        jmp NEWSTT
        rts

IERROR_GO:
        jsr IERROR_CLR
;        LDY #MSG2_2-MSGBAS2    ; display "?" to indicate error and go to new line
;        JSR SNDMSG2
        LDA #0            ; disable kernel control messages
        JSR SETMSG        ; and enable error messages

        lda #> PRGEND     ; check if kmon was overwritten
        cmp TXTTAB+1
        bcs run_mon       ; load kmon back first
        jmp STRT          ; go to kmon main

IERROR_SET:
        ldx #3
@l1:    lda IERROR,X
        sta IERROR_OLD,X
        lda IERROR_NEW,X
        sta IERROR,X
        dex
        bpl @l1
        rts
IERROR_CLR:
        ldx #3
@l1:    lda IERROR_OLD,X
        sta IERROR,X
        dex
        bpl @l1
        rts

IERROR_OLD:
        .word $0000,$0000
IERROR_NEW:
        .word IERROR_GO, IERROR_GO

SNDMSG2: 
        LDA MSGBAS2,Y        ; Y contains offset in msg table
        PHP
        AND #$7F            ; strip high bit before output
        JSR CHOUT
        INY
        PLP
        BPL SNDMSG2          ; loop until high bit is set
        RTS

MSGBAS2  =*
MSG2_0:.BYTE $0d,"..RUN",$0D+$80
MSG2_1:.BYTE $0d,"?EIO",$20+$80
TB_FNLEN: .byte 4
TB_FN:    .byte "KMON            "

.segment "CARTHDR"
        ; cartridge header
        .addr hardrst   ; hard reset vector
        .addr $fe5e     ; soft reset vector:return to NMI handler immediately after cartridge check
MAGIC:
        .byte $C3, $C2, $CD, $38, $30   ; 'CBM80' magic number for autostart cartridge

hardrst:
        STX $D016       ; modified version of RESET routine (normally at $FCEF-$FCFE)
        JSR IOINIT
        JSR RAMTAS
        JSR RESTOR
        JSR CINT        ; video init

SAVCOLOR:
        LDA #15
        STA COLOR
SAVEXTCOL:
        LDA #15
        STA EXTCOL
SAVBGCOL0:
        lda #11
        STA BGCOL0

        CLI
        JSR $E453       ; modified version of BASIC cold-start (normally at $E394-$E39F)
        JSR $E3BF
        JSR $E422
        LDX #$FB
        TXS

        LDA #14
        JSR CHROUT
        LDA #$80            ; disable kernel control messages
        JSR SETMSG          ; and enable error messages
        JSR INSTALL_TBUFFR

        lda #0
        sta MAGIC           ; disable cartridge autostart

        ; set filename
        lda CH_FNLEN
        sta TB_FNLEN
        tax
        ldy #0
@l1:    lda CH_FN,Y
        sta TB_FN,Y
        iny
        dex
        bne @l1

        JMP __TBUFFR_RUN__
        JMP $A478       ; jump into BASIC

CH_FNLEN:.byte 2
CH_FN:   .byte ":*" 
