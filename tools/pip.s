; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.ifdef __C128__
.include "defs128.inc"
.else
.include "defs64.inc"
.forceimport __EXEHDR__
.endif
.include "macros.inc"

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.

pipfhi = 2
pipfho = 3
debug  = 0

; .segment "STARTUP"
start:
        jmp main

        rts

; -----------------------------------------------------------------------------
; variables
SIZE:   .word 0
FA1:    .byte 8
FNADR1: .word 0
FNLEN1: .byte 0   
FNLEN2: .byte 0

.include "utils.s"

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .byte "run64 pip 0.5 ",$80
MSG1:   .BYTE "copying ",$80,0
MSG2:   .BYTE "error ",$80,0
MSG3:   .BYTE $1D,$3F+$80       ; syntax error:move right, display "?"
MSG4:   .BYTE " bytes.",13+$80,0

; -----------------------------------------------------------------------------
; main program
main:
.ifdef DEBUG
; echo args for debug
        LDA COUNT
        JSR WRTWO
        LDX #0
@L:     LDA $200,x
        JSR WRTWO
        INX
        CPX #88
        BNE @L
.endif

        lda BUF      ; if run from shell or basic
        bpl main1    ; check if basic token
        lda #0
        sta init_state
        jmp main2    ; we were run from BASIC with "run"

main1:  lda COUNT    ; we were run from shell
        sta CHRPNT   ; restor command line pointer

        tax
        ldy #0

        JSR GOTCHR
        bne args
        jmp main2    ; no arguments

args:
        jsr GETOPT      ; get leading options
        jsr GETFNADR
        bne @l2
        rts
@l2:
        jsr SETNAMX

        jsr GETOPT      ; get trailing options

; switch to lowercase if /a option
        lda CLIOPT
        and #$02
        beq @n1
        lda #14
        jsr CHROUT
@n1:

        ldy #0
@l31:
        lda (FNADR),Y
        cmp #'='
        beq prep_copy
        iny
        cmp FNLEN
        bcs @l31
        jmp open_files

; separate source and destination names
; source becomes current file, destination goes to FNADR1 and FNLEN1
prep_copy:   
        lda FNLEN
        sty FNLEN1
        sec
        sbc FNLEN1
        sta FNLEN
        dec FNLEN
        sec
        lda FNADR
        sta FNADR1
        adc FNLEN1
        sta FNADR
        lda FNADR+1
        sta FNADR1+1
        adc #0
        sta FNADR+1

open_files:
        lda FNLEN
        sta FNLEN2
        beq @of1
        ; open input
        lda #pipfhi
        tay
        ldx FA
        jsr SETLFS
        jsr OPEN
        bcc @of1
        jmp error
        ; input opened        
@of1:
        ; open output
        lda FNLEN1
        beq redirect     ; no output

        LDY #MSG1-MSGBAS    ; display
        JSR SNDMSG
        jsr print_name
        jsr CRLF

        lda FNLEN1
        ldx FNADR1
        ldy FNADR1+1
        jsr SETNAMX

        lda #pipfho
        tay
        ldx FA
        jsr SETLFS
        jsr OPEN
        bcc redirect     ; succesful open

;        lda #'!'
;        jsr CHROUT

        jmp error
        ; output opened        

;        LDY #MSG1-MSGBAS    ; display copying...
;        JSR SNDMSG
;        JSR CRLF

redirect:
        ; set input
        lda FNLEN2
        beq @rdro
        ldx #pipfhi
        jsr CHKIN
@rdro:
        lda FNLEN1
        beq copy_loop
        ldx #pipfho
;        jsr CHKOUT

        ldy #0
copy_loop:
        jsr GETIN
        tax
        jsr READST
        bne feof

        ; enable quote mode
        ; most controls are displayed as reverse characters

        lda #$FF
        sta QTSW

        txa

        ; check for tab
        cmp #9
        bne @l2

        lda #0
        sta QTSW
        txa

@l2:
;        jsr CHROUT
        jsr PUTCHR
        jsr READST
        bne feof

        inc SIZE
        bne @l1
        inc SIZE+1
@l1:

        jsr STOP
        bne copy_loop
        ; stop pressed

feof:
        AND #$BF
        beq done
        jsr error

done:
        jsr finish
        jsr CRLF

        ; print byte count
        ldx SIZE
        lda SIZE+1
        jsr LINPRT
        LDY #MSG4-MSGBAS    ; display
        JSR SNDMSG

        ; exit
        lda init_state
        bne main3
        rts

init_state:
        .byte 0

main2:  ; interactive mode
        lda init_state
        bne main3
        inc init_state

        LDY #MSG0-MSGBAS    ; display
        JSR SNDMSG

        ; interactive mode here,,,
        ; print free memory
        sec
        lda FRETOP
        sbc STREND
        tax
        lda FRETOP+1
        sbc STREND+1
        jsr LINPRT

        LDY #MSG4-MSGBAS    ; display "bytes."
        JSR SNDMSG

;        jsr chartable

main3:   ; prompt
        lda #'*'
        jsr CHROUT

        ; read one line of input into BUF
        ldx #0
        stx CHRPNT
@SMOVE: jsr CHRIN
        sta BUF+1,X
        inx
        CPX #ENDIN-BUF-1   ; error if buffer is full
        BCS @error
        cmp #13             ; keep reading until CR
        bne @SMOVE
        LDA #0              ; null-terminate input buffer
        STA BUF,X         ; (replacing the CR)

        stx COUNT
        dec COUNT
        bne @ml5            ; some input

        rts                 ; no input, exit program
@error:
        LDY #MSG3-MSGBAS    ; display "?" to indicate error and go to new line
        JSR SNDMSG
        JMP main3           ; back to main input loop

@ml5:
        lda #13
        jsr CHROUT

        lda #1
        sta COUNT

        jmp main1           ; run input

;----------------------------------------------
.proc finish
        jsr CLRCHN
        lda #pipfhi
        jsr CLOSE
        lda #pipfho
        jsr CLOSE
        rts
.endproc
;----------------------------------------------

.proc error
        jsr finish
        jsr print_name
        LDY #MSG2-MSGBAS    ; display
        JSR SNDMSG
        jsr READST
        jsr WRTWO
        jsr CRLF
        jsr DOS_INSTAT
        rts
.endproc

.proc chartable
        jsr CRLF

        lda #$20
        sta T0

        ldx #6
        ldy #0
@l1:
        tya
        clc
        adc T0   
        jsr PUTCHR
        lda #' '
        jsr CHROUT

        iny
        tya
        and #$0f
        bne @l1
        jsr CRLF

        dex
        bne @l1

        jsr CRLF
        rts

T0:     .byte 0
.endproc

; -----------------------------------------------------------------------------
; output a character

.proc PUTCHR
;        jsr CONVERT
;        jmp CHROUT
;        rts

        pha
        lda CLIOPT
        and #$02
        beq @l11
        pla
        jsr CONVERT    ; convert ANSI to PETSCII
        nop2
@l11:
        pla
        jmp CHROUT
        rts
.endproc

; -----------------------------------------------------------------------------
; convert .a ASCII/ANSI to PETSCII
.proc CONVERT
        cmp #10
        bne c1
        lda #13
        rts
c1:
        cmp #$41
        bcc crts
        cmp #$5b
        bcs c10
        clc
        adc #$20   ; change case
        rts
c10:
        cmp #$5c   ; '\'
        bne c11
        lda #191
        rts
c11:
        cmp #$5f   ; '_'
        bne c2
        lda #164
        rts
c2:
        cmp #$61
        bcc crts
        cmp #$7b        
        bcs c3
        sec
        sbc #$20   ; change case
        rts

c3:
        cmp #$7b   ; '{'
        bne c31
        lda #179
        rts
c31:
        cmp #$7c   ; '|'
        bne c32
        lda #221
        rts
c32:
        cmp #$7d   ; '}'
        bne crts
        lda #171
crts:
        rts
.endproc

; -----------------------------------------------------------------------------
; parse command line options 
CLIOPT:    .byte 0,0,0,0

.proc GETOPT 
        jsr GETSPC
        cmp #'/'
        bne done
        jsr GETCHR
        beq done
        ; decode option
        and #$1f
        ldx #0
        tay
@l3:    lda #1
        clc
@l1:    asl
        bcc @l2
        inx
        bne @l3
        BRK     ; 
@l2:    dey
        bne @l1
        ora CLIOPT,x
        sta CLIOPT,x
        ; next option
        jmp GETOPT
done:
        dec CHRPNT

        rts
.endproc

; -----------------------------------------------------------------------------
; set filename and optional device number 
.proc SETNAMX
        jsr SETNAM
        ldy #1
        lda (FNADR),Y
        cmp #':'
        bne @done
                DEY
                lda (FNADR),y
                jsr SETDEV
                beq @done
                        clc
                        lda FNADR
                        adc #2
                        sta FNADR
                        lda FNADR+1
                        adc #0
                        sta FNADR+1
                        dec FNLEN
                        dec FNLEN
        @done:
        rts
.endproc

; -----------------------------------------------------------------------------
; set device in .a
.proc SETDEV
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
                rts
        @sdx:
        sta FA
        rts
.endproc

.include "dos.inc"

; -----------------------------------------------------------------------------
; main program
.proc print_name
        pha
        tya
        pha
        lda #'"'
        jsr CHROUT
        ldy #0
@p1:    lda (FNADR),y
        jsr CHROUT
        iny
        cpy FNLEN
        bne @p1
        lda #'"'
        jsr CHROUT
        lda #' '
        jsr CHROUT
        pla
        tay
        pla
        rts
.endproc

.segment "INIT"