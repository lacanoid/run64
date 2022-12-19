; -----------------------------------------------------------------------------
; Tape buffer (resident) section
.segment "TBUFFR"
 jrunmon:
        jmp run_mon
 jrunprg:
        jmp run_prg
; -----------------------------------------------------------------------------
loadflags:
        .word 0
runflags:
        .word $80
loaddev:
        .word 8
; run a monitor
run_mon:
.ifdef __C128__
        ; switch ROMs in
        lda #0
        sta $FF00
        sta FNBANK
.endif
        lda TB_FNLEN
        leaxy TB_FN
        JSR SETNAM
        lda loaddev
        sta FA
        ldy #0
        nop3
; run a different program, must call setnam beforhand
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

        bit runflags
        bmi TBSTART2
        jmp (ISOFT_RESET)
TBSTART2:
        lda #$0D
        jsr CHROUT

.ifdef __C128__
.else
        ldxy EAL
        stxy VARTAB
.endif

        ; start a program
.ifdef __C128__
        jmp JRUN_A_PROGRAM
.else
        jsr LINKPRG
        jsr RUNC
        jsr STXTPT
        jmp NEWSTT
.endif
;        rts

IERROR_GO:
        lda NDX           ; number of keystrokes
;        sta VICSCN
        beq @ieg1
        jmp (IERROR_OLD)
;        jmp $A483         ; run basic MAIN if keys pressed
@ieg1:
        jsr IERROR_CLR
;        LDY #MSG2_2-MSGBAS2    ; display "?" to indicate error and go to new line
;        JSR SNDMSG2
        LDA #0            ; disable kernel control messages
        JSR SETMSG        ; and enable error messages

.ifdef __C128__
        jmp run_mon       ; load kmon back first
.else
        lda #> PRGEND     ; check if kmon was overwritten
        cmp TXTTAB+1
        bcs run_mon       ; load kmon back first
        jmp STRT          ; go to kmon main
.endif

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
        JSR CHROUT
        INY
        PLP
        BPL SNDMSG2          ; loop until high bit is set
        RTS

MSGBAS2  =*
MSG2_1:   .BYTE $0d,"?",$20+$80
.ifdef __C128__
TB_FNLEN: .byte 8
TB_FN:    .byte "kmon.128",0
          .res  6
.else
TB_FNLEN: .byte 7
TB_FN:    .byte "kmon.64"
          .res  7
.endif

; -----------------------------------------------------------------------------
; c64 cartridge to autoboot programs
; requires above loader in TBUFFER

.ifdef __C64__
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
        ; set device
        lda CH_FA
        sta FA
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

CH_FA:   .byte 8        ; boot device number
CH_FNLEN:.byte 2
CH_FN:   .byte ":*" 
.endif ; C64
