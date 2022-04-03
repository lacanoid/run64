.macro GenericEntry id, name, label, payload, q 
  .scope
    ::.ident (.string(name))=entry 
    entry:
      .byte id
      .addr __runtime__ 
      .ifblank payload 
        .byte payload $0
      .else
        .byte payload
      .endif
      .addr __next_entry__
      .addr __compile__
      .addr __list__
      .ifnblank q
        .byte label, q, 0;
      .else 
        .ifblank label
          .asciiz .string(name)
        .else
          .asciiz label
        .endif
      .endif
    __runtime__:
  .endscope
.endmacro

.macro rEntry name, label, q
  GenericEntry bytecode::NAT, name, label,0,q
.endmacro

.macro jEntry name, label, q
  GenericEntry bytecode::NAT, name, label,0,q
.endmacro

.macro cEntry name, label,q
  GenericEntry bytecode::NAT, name, label, 1, q
.endmacro


.macro CMD name, label, q
  .scope
    DEF_CMD = 1
    cEntry name, label,q
.endmacro

.macro PROC name, label, q
  .scope
    DEF_PROC = 1
    jEntry name, label, q
.endmacro

.macro DEF name, label, q
  .scope
    DEF_RUN = 1
    rEntry name, label, q
    DOCOL
.endmacro

.macro COMPILE
  .ifdef DEF_RUN
    rRet
  .endif
  __compile__:
.endmacro

.macro LIST
  .ifdef DEF_RUN
    rRet
  .endif
  __list__:
.endmacro

.macro END name, label
    .ifdef DEF_RUN 
      _ EXIT
      rts
    .elseif .def (DEF_PROC)
      NEXT
    .endif
    .ifndef __compile__
      __compile__ = DEFAULT_COMPILER ; default compiler
    .endif
    .ifndef __list__
      __list__ = DEFAULT_LISTER ; default lister
    .endif
    .ifndef __next_entry__
      __next_entry__:
    .endif
  .endScope
.endmacro

