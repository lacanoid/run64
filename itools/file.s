.ifndef ::__FILE_INCLUDED__
::__FILE_INCLUDED__=1
.include "xy.s"
.macro file fn
  jsr file::fn
.endmacro

.scope file
  FILE_NAME_LENGTH = $B7
  CUR_FILE = $B8
  CUR_SA  = $B9
  CUR_DEV = $BA
  FILE_NAME  = $BB
  FILES_OPEN = $98
  FILES_TABLE = $0259
  
  .proc open                ; ptr to filename in XY, device number in A
    jsr _prepare
    ldx #0
    ldy #2
    beq _open
  .endproc

  .proc open_l                ; ptr to filename in XY, device number in A
    jsr _prepare
    ldx #1
    ldy #0
    beq _open
  .endproc

  .proc open_s                ; ptr to filename in XY, device number in A
    jsr _prepare
    ldx #2
    ldy #1
    bne _open
  .endproc

  .proc open_r                ; ptr to filename in XY, device number in A
    jsr _prepare
    ldx #1
    ldy #2
    bne _open
  .endproc

  .proc open_w                ; ptr to filename in XY, device number in A
    jsr _prepare
    ldx #2
    ldy #2
    bne _open
  .endproc

  .proc open_rw               ; ptr to filename in XY, device number in A
    jsr _prepare
    ldx #3
    ldy #2
    bne _open
  .endproc

  .proc open_cmd               ; ptr to filename in XY, device number in A
    jsr _prepare
    ldx #3
    ldy #15
    bne _open
  .endproc
  
  .proc _prepare 
    ; IN - pointer to file name in XX, device number in A
    ; OUT - first free logical file number in A
    sta CUR_DEV
    stxy FILE_NAME
    jsr xy::findz
    sta FILE_NAME_LENGTH
    ldy #$20
    find:
      iny
      tya
      ldx FILES_OPEN                   ;
      check:
        dex 
        bmi found
        cmp FILES_TABLE,x
      bne check
    beq find 
    found:
    sta CUR_FILE
    rts
  .endproc


  .proc _open
    .pushseg
    .data
      FILE: .byte 1
    .popseg 
    ; IN - file number in A, secondary address in Y, chkin in bit0 of x, chkout in bit1 of x
    ; OUT - logical file number in A
      sta FILE
      sty CUR_SA
      txa
      and #1
      sta rwin+1
      txa
      and #2
      sta rwout+1

      jsr OPEN
      bcs error

      rwin: ldx #00
      beq no_chkin
        ldx FILE
        jsr CHKIN
        bcs close
      no_chkin:

      rwout: ldx #00
      beq no_chkout
        ldx FILE
        jsr CHKOUT
        bcs close
      no_chkout:
    lda FILE
    clc
    rts
    close:
      pha
      jsr CLOSE
      pla
      sec
      rts
    error:
      rts
  .endproc 

  .proc read_busy
    inc 53280
  .endproc
  .proc read
    jsr READST      ; call READST (read status byte)
    bne st          ; read error or end of file
    
    jsr CHRIN       ; call CHRIN (read byte from file)
    clc 
    bcc exit
    st: 
    cmp #64
    bne err
    lda #0
    err:
    sec
    exit:
    rts
  .endproc
.endscope
.endif