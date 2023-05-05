; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.ifdef __C128__
.include "defs128.inc"
.else
.ifdef __C16__
.include "defs16.inc"
.else
.include "defs64.inc"
.forceimport __EXEHDR__
.endif
.endif
.include "macros.inc"

.import __TBUFFR_SIZE__, __TBUFFR_LOAD__, __TBUFFR_RUN__
.import __CARTHDR_SIZE__, __CARTHDR_LOAD__, __CARTHDR_RUN__
.import __EXT1_RUN__, __EXT1_LOAD__, __EXT1_SIZE__

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

.segment "CODE"
; -----------------------------------------------------------------------------
; initial entry point
SUPER: 
        LDY #MSG4-MSGBAS    ; display "..SYS "
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

        LDA #$80            ; disable kernel control messages
        JSR SETMSG          ; and enable error messages

        ldxy IERROR
        stxy ON_ERR_SAV

        jsr CRLF
        jmp kmon

        ; set BRK vector
        LDA LINKAD
        STA IBRK
        LDA LINKAD+1
        STA IBRK+1

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
        jsr WRTWO
        jsr SPACE
        ldx PCL
        ldy PCH
        jsr hexoutxy
        jsr SPACE
        lda ACC
        jsr WRTWO
        jsr CRLF
; -----------------------------------------------------------------------------
; kmon init
kmon:
        TSX                 ; store stack pointer in memory 
        STX SP

        LDY #MSG0-MSGBAS    ; display 
        JSR SNDMSG

; -----------------------------------------------------------------------------
; switch to fast mode if c128 80 column mode
.ifdef __C128__
        lda MODE
        bpl @nofast
        jsr FAST
@nofast:
.endif

; -----------------------------------------------------------------------------
; parse args
        LDA BUF
        BMI noargs   ; no args
        BEQ noargs
main1:  
        lda COUNT    ; we were run from shell
        jsr WRTWO

        lda COUNT
        sta CHRPNT   ; restore command line pointer
        beq noargs

        ldx #0
@l3:    lda BUF,X
        beq @l2
        inx
        bne @l3
@l2:
        txa
        jsr WRTWO

        cpx CHRPNT
        bcc noargs
 
        ; copy args to input buffer and run it
        ldy CHRPNT
        ldx #0
@l1:    lda BUF,y
        bne @l4
        stx COUNT
@l4:    sta BUF,x
        inx
        iny
        CPY #ENDIN-BUF
        BCC @l1

        jmp STRT2   ; execute buffer
noargs:
.include "core.s"

; -----------------------------------------------------------------------------
; single-character commands
KEYW:   .byte "bcdeghijk'"
        .byte "mnor^x@>#."
HIKEY:  .byte "$+&%lsv"
KEYTOP  =*

; vectors corresponding to commands above
KADDR:  .WORD CMDBOOT-1, CMDCHDIR-1, CMDDIR-1, CMDLIST-1, GOTO-1, DSPLYH-1, DSPLYI-1, JSUB-1, CMDKEYS-1, CMDKEYS-1
        .WORD DSPLYM-1, CMDNEW-1, CMDOLD-1, CMDRUN-1, CMDRUN-1, EXIT-1, DSTAT-1, ALTM-1, TRIGRAM-1, SUBFILE-1

; -----------------------------------------------------------------------------
; exit monitor [X]
EXIT:   
        ldxy ON_ERR_SAV
        stxy IERROR
        JMP (ISOFT_RESET)   ; jump to warm-start vector to reinitialize BASIC

; -----------------------------------------------------------------------------
; variables

;SAVX:   .res 1             ; 1 byte temp storage, often to save X register
;SAVY:   .res 1             ; 1 byte temp storage, often to save Y register
DIGCNT: .res 1              ; digit count
INDIG:  .res 1              ; numeric value of single digit
NUMBIT: .res 1              ; numeric base of input
STASH:  .res 2              ; 2-byte temp storage
U0AA0:  .res 10             ; work buffer
U0AAE   =*                  ; end of work buffer
STAGE:  .res 30             ; staging buffer for filename, search, etc.
ESTAGE  =*                  ; end of staging buffer
STORE:  .res 2              ; 2-byte temp storage
;CHRPNT: .res 1             ; current position in input buffer

PCH:    .res 1             ; program counter high byte
PCL:    .res 1             ; program counter low byte
SR:     .res 1             ; status register
ACC:    .res 1             ; accumulator
XR:     .res 1             ; X register
YR:     .res 1             ; Y register
SP:     .res 1             ; stack pointer

.include "dos.s"

; -----------------------------------------------------------------------------
; new [N] set memory bounds and perform NEW
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
ALTM:   JSR GETPAR
        BCS ALTMX           ; exit if no parameter provided
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
GOTO:   JSR GETPAR
        LDX SP              ; load stack pointer from memory
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
JSUB:   JSR GETPAR
        LDX SP              ; load stack pointer from memory
        TXS                 ; save value in SP register
        JSR GOTO2           ; same as goto command
        STY YR              ; save Y to memory
        STX XR              ; save X to memory
        STA ACC             ; save accumulator to memory
        PHP                 ; push processor status on stack
        PLA                 ; pull processor status into A
        STA SR              ; save processor status to memory
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

TRIGRAM_IN:
        lda #0
        sta TMP0
        sta TMP1

        JSR GETCHR    ; 1-st char 
        beq @tg9
        and #$1f
        sta TMP0

        JSR GETCHR    ; 2-nd char
        beq @tg9
        pha
        and #$F0      
        cmp #$30
        bne @tg2 
; is it a number
        lda TMP1
        ora #$fe
        sta TMP1

@tg2:   ; letter
        pla
        and #$3f

        ldx #5
@tg1:   asl
        rol TMP1        
        dex
        bne @tg1
        ora TMP0
        sta TMP0

        JSR GETCHR    ; 3-rd char 6 bits
        beq @tg9
        and #$3f
        asl
        asl
        ora TMP1
        sta TMP1
@tg9:
        rts

TRIGRAM:
        jsr TRIGRAM_IN
        JMP CONVRT1


; -----------------------------------------------------------------------------
.include "utils.s"
; -----------------------------------------------------------------------------
; message table; last character has high bit set

MSGBAS  =*
MSG0:   .BYTE 14
        .BYTE "kmon"
.ifdef __C128__
        .byte "128"
.else
        .byte "64"
.endif
        .byte " 0.9",' '+$80
MSG1:   .BYTE $0D               ; header for registers
        .BYTE "*err",'*'+$80
MSG2:   .BYTE $0D               ; header for registers
        .BYTE "*brk*",$20+$80
MSG3:   .BYTE $1D,$3F+$80       ; syntax error:move right, display "?"
MSG4:   .byte "..sys"           ; SYS call to enter monitor
        .BYTE $20+$80
MSG5:   .BYTE $3A,$12+$80       ; ":" then RVS ON for memory ASCII dump
MSG6:   .byte " error",$80      ; I/O error:display " ERROR"
MSG7:   .BYTE $41,$20+$80       ; assemble next instruction:"A " + addr
MSG8:   .byte "  "              ; pad non-existent byte:skip 3 spaces
        .BYTE $20+$80


; -----------------------------------------------------------------------------

prompt:
        .asciiz "!"

;----------------------------------------

cmdold: lda #1
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
;        jsr listvars
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
msg1:    .asciiz "txttab "
msg2:    .asciiz "vartab "
;msg3:    .asciiz "ARYTAB "
msg4:    .asciiz "strend "
msg5:    .asciiz "fretop "
msg6:    .asciiz "memsiz "
;msgN:    .asciiz "MEMTOP "
;msgSAL:  .asciiz "SAL    "
msgEAL:  .asciiz "eal    "
msgFNADR:.asciiz "fnadr  "

DSPLYI: jsr CRLF
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

msgb1: .asciiz "ierror "
msgb2: .asciiz "imain  "
msgb3: .asciiz "icrnch "
msgb4: .asciiz "iqplop "
msgb5: .asciiz "igone  "
msgb6: .asciiz "ieval  "

vectorinfo:
        msg msgc1
        ldxy IIRQ
        jsr hexoutxynl
        msg msgc2
        ldxy IBRK
        jsr hexoutxynl
        msg msgc3
        ldxy INMI
        jsr hexoutxynl
        rts

msgc1: .asciiz "iirq   "
msgc2: .asciiz "ibrk   "
msgc3: .asciiz "inmi   "

msgout:  stx T1
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
        jsr WRTWO
        txa 
        jsr WRTWO
        rts

; hexout:
;         pha
;         pha
;         lsr
;         lsr
;         lsr
;         lsr
;         jsr hexdig
;         jsr CHROUT
;         pla
;         and #$0f
;         jsr hexdig
;         jsr CHROUT
;         pla
;         rts
hexdig:
        cmp #$0a
        bcc hdsk1
        adc #$06
 hdsk1: adc #$30
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
; load a program and switch to editor

CMDOLD:
        jsr INSTALL_TBUFFR
        lda #0
        sta runflags
        jsr GETFNADR
        beq CMDOLD1
CMDOLDGO:
        JSR SETNAMX
.ifdef __C128__
        jsr set_autosave_key
.endif
        lda CHRPNT
        sta COUNT      

        ; call resident code in TBUFF which does not return on success
        jsr jrunprg
        bcc CMDOLD1   ; no error
        jsr WRTWO    ; print error code
        lda #'@'
        sta BUF
        lda #0
        sta BUF+1
        JMP STRT2
CMDOLD1:
        rts

.ifdef __C128__
set_autosave_key:
@s0:
        lda #0
        sta TMP0+2

        leaxy STAGE
        stxy  TMP0

        lda #0
        tax
        tay

@s1:    lda sak_def,Y
        sta STAGE,X
        beq @sd
        cmp #1
        bne @s2
        jsr sak_fnam
        dex
@s2:    
        inx
        iny
        bne @s1
        rts  ; overflow
@sd:
        txa
        tay
        
        ldx FA
        txa
        cpx #10
        bcc @sdn1
        lda #'1'
        sta STAGE,Y
        iny
        txa
        sec
        sbc #10
@sdn1:  clc
        adc #'0'
        sta STAGE,Y
        iny

        lda #TMP0  ; ZP register
        ldx #8     ; key number
        jsr JPFKEY ; redefine key
        rts

sak_def:
        .byte "save",34,"@:",1,34,",",0

; insert current filename
sak_fnam:
        tya
        pha

        ldy #0
@l1:    cpy FNLEN
        beq @sfn1
@l2:    lda (FNADR),Y
        sta STAGE,x
        inx
        iny
        bne @l1
@sfn1:
;        dex

@lx:    pla
        tay
        rts
.endif ; __C128__

; -----------------------------------------------------------------------------
CMDBOOT:
        ; configure cartridge with boot filename
.ifdef __C64__
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
.endif
CMDBOOT1:
        jmp ($FFFC)
CMDBOOTX:
        rts

; -----------------------------------------------------------------------------
INSTALL_CARTHDR:
.ifdef __C64__
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
.endif
        RTS

INSTALL_TBUFFR:
        LDX  #< (__TBUFFR_SIZE__ + 1)
@loop:  LDA __TBUFFR_LOAD__ - 1, X
        STA __TBUFFR_RUN__ - 1, X
        DEX
        BNE @loop
        RTS

; -----------------------------------------------------------------------------
; save command line on stack
BUF_SAVE:
        ldx #88
@l:     lda BUF,X
        sta $160,X
        dex
        bpl @l 
        rts

; -----------------------------------------------------------------------------
; load and run a program

CMDRUN:
        jsr INSTALL_TBUFFR
.ifdef __C128__
        jsr BUF_SAVE
.endif
        jsr GETFNADR
        beq CMDRUNLOADED
CMDRUNGO:
        JSR SETNAMX

        lda CHRPNT
        sta COUNT      

; clear to end of screen
.ifdef __C128__
        jsr JPRIMM
        .byte 13,27,"@",$91,0
.endif

; call resident code in TBUFF which does not return on success
        jsr CLRCHN
        jsr jrunprg
        bcc CMDRUN1   ; no error

        jsr WRTWO    ; print error code
DOS_ERROR:
        lda #'@'
        sta BUF
        lda #0
        sta BUF+1
        lDA #1
        STA COUNT
        JMP STRT2
CMDRUN1:
        rts


; -----------------------------------------------------------------------------
; run already loaded program
CMDRUNLOADED:
.ifdef __C128__
        jsr JRUN_A_PROGRAM
.else
        jsr ON_ERR_SET
        jsr CRLF
        jsr LINKPRG
        jsr RUNC
        jsr STXTPT
        jmp NEWSTT
.endif
        rts

; -----------------------------------------------------------------------------
; set filename and optional device number 

SETNAMX:
        jsr SETNAM
        ldy #1
        lda (FNADR),Y
        cmp #':'
        bne @sndone
        DEY
        lda (FNADR),y
        jsr SETDEV
        clc
        lda FNADR
        adc #2
        sta FNADR
        lda FNADR+1
        adc #0
        sta FNADR+1
        dec FNLEN
        dec FNLEN
@sndone:
        rts

; -----------------------------------------------------------------------------
; set device in .a
SETDEV:
        cmp #'0'
        bcc @sde
        cmp #64
        bcs @sd2
        sbc #'0'-1
        bpl @sdx
@sd2:
        sbc #64-9
        bpl @sdx
@sde:
        lda 0
@sdx:
        sta FA
        rts


; -----------------------------------------------------------------------------
CMDLIST:
        jsr ON_ERR_SET
        jsr LINKPRG
        jsr RUNC
        jsr LIST
        rts

; -----------------------------------------------------------------------------
.proc CMDCHDIR           ; change directory command
        jsr GETPAR
        bcs CMDCD3
        lda TMP0
        sta FA
CMDCD3:
        jmp STRT
.endproc

; -----------------------------------------------------------------------------
.proc CMDDIR           ; directory command
        jsr GETPAR
        bcs CMDDI3
        lda TMP0
        sta FA
CMDDI3:
        ldx #0
CMDDI2: lda CMDDI0,X
        sta BUF,X
        bne CMDDI1
;        lda FA       ; substitute current device number
;        jsr hexdig
;        sta BUF+1
;        inx         ; end of command
        stx COUNT
        jmp STRT2
CMDDI1: inx
        bpl CMDDI2
        brk
        rts

CMDDI0:.asciiz "@$"
.endproc

; -----------------------------------------------------------------------------
; push text into input stream

.proc CMDKEYS
        jsr install
args1:
        JSR GETCHR
        BEQ args9   ; end of string
        CMP #$20        ; skip leading spaces
        BEQ args1
        ldy #0
args2:
        cmp #$5f    ; is it _
        bne args21
        lda #13
args21:
        STA keys_ext1,Y
        iny
        beq args5
        jsr GETCHR
        bne args2

args5:
        lda #0
        sta keys_ext1,Y
args9:
        jsr vec_set
        jmp STRT
args99:

;-- init code      -----

install:
        LDX  #< (__EXT1_SIZE__ + 1)
@loop:  LDA __EXT1_LOAD__ - 1, X
        STA __EXT1_RUN__ - 1, X
        DEX
        BNE @loop
        rts

vec_set:
        sei
        lda IIRQ
        sta irq_cont+1
        lda #<irq_new
        sta IIRQ
        lda IIRQ+1
        sta irq_cont+2
        lda #>irq_new
        sta IIRQ+1
        cli
        rts

payload:
; payload
.segment "EXT1"
code_begin:
vec_clr:
        sei
        lda irq_cont+1
        sta IIRQ
        lda irq_cont+2
        sta IIRQ+1
        cli
        rts

;-- variables      -----
index:
        .byt 0

; -------------------------

irq_new:
        lda NDX
        bne irq_cont   ; there is stuff in kb buffer
        ; add a character to input
        ldx index
        lda keys_ext1,X
        beq irq_err
        sta KEYD
        inc NDX
        inc index
        bne irq_cont

irq_err:
        jsr vec_clr

irq_cont:
        jmp $fa65


keys_ext1:
        .byt 0
        .res 80
        .byt 0

code_end:
.endproc

.segment "CODE"

; -----------------------------------------------------------------------------
; submit file < command
; this redirects input from a file

subfilefhi = 14

.proc SUBFILE
        lda #$c0 
        jsr SETMSG

        jsr GETFNADR
        beq @of1       ; no args
        bne @l2        ; args
        jmp ERROR
@l2:
        jsr SETNAMX

        lda #subfilefhi
        tay
        ldx FA
        jsr SETLFS

        lda #subfilefhi
        jsr CLOSE
        jsr OPEN
        bcc @of1
        jmp ERROR
        ; input opened        
@of1:
; redirect input
        ldx #subfilefhi
        jsr CHKIN
        bcc @of2
@of2:
        jmp STRT
.endproc

.include "loader.s"

.segment "CODE"

; -----------------------------------------------------------------------------
; translate input 
translate:
        leaxy UCLDAT
        stxy INDEX

@loop0:
        ldy #1
        lda (INDEX),Y
        beq @end

        ldx CHRPNT
        ldy #4
@loop:
        lda (INDEX),Y
        beq @next 
        cmp #' '
        bne @l1
        iny
        bne @loop
@l1:
        cmp #'='
        bne @cont
@found:
        lda (INDEX),Y
        beq @end
        jsr CHROUT
        iny
        bne @found
        jmp @end
@cont:
        cmp BUF,X
        bne @next

;        jsr CHROUT
        INY
        INX
        bne @loop

@next:
        ldy #0
        lda (INDEX),Y
        pha
        iny
        lda (INDEX),Y
        sta INDEX+1
        pla
        sta INDEX
        jmp @loop0
@end:
        rts

; -----------------------------------------------------------------------------
ERRAD:  .word ON_ERR            ;
LINKAD: .WORD BREAK             ; address of brk handler
SUPAD:  .WORD SUPER             ; address of entry point
PRGEND:
        .byte 0
UCLDAT:
        .word @l20, 10
        .byte "dir=@$:",0
@l20:   .word @l30, 20
        .byte "type=^pip /a ",0
@l30:   .word @l40, 30
        .byte "run=^",0
@l40:   .word 0
