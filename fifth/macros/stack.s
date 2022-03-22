
.macro SP_LOAD
  ldx SP
.endmacro

.macro SP_INC
    inx
    inx
    stx SP
.endmacro

.macro SP_DEC
    dex
    dex
    stx SP
.endmacro

.macro GET_LO d
    lda STACK-d*2,x
.endmacro

.macro GET_HI d
    lda STACK-d*2+1,x
.endmacro

.macro INSERT d, arg
    lda #<arg
    sta STACK-d*2,x
    lda #>arg
    sta STACK-d*2+1,x
.endmacro

.macro INSERT_A d
    sta STACK-d*2,x
    lda #0
    sta STACK-d*2+1,x
.endmacro

.macro INSERT_FROM d, address
    lda address
    sta STACK-d*2,x
    lda address+1
    sta STACK-d*2+1,x
.endmacro

.macro INSERT_BYTE_FROM d, address
    lda address
    INSERT_A d
.endmacro

.macro COPY c, d
    lda STACK-c*2,x
    sta STACK-d*2,x
    lda STACK-c*2+1,x
    sta STACK-d*2+1,x
.endmacro

.macro COPY_TO c, address
    lda STACK-c*2,x
    sta address
    lda STACK-c*2+1,x
    sta address+1
.endmacro

.macro COPY_BYTE_TO c, address
    lda STACK-c*2,x
    sta address
.endmacro

.macro PUSH arg
    INSERT 0, arg
    SP_INC 
.endmacro

.macro PUSH_A
    INSERT_A 0
    SP_INC 
.endmacro

.macro PUSH_FROM address
    INSERT_FROM 0, address
    SP_INC 
.endmacro

.macro PUSH_BYTE_FROM address
    INSERT_BYTE_FROM 0, address
    SP_INC 
.endmacro

