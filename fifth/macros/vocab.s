
.macro GenericEntry  flags, name, label, q 
  .scope
    ::.ident (.string(name))=entry 
    entry:
      .byte $4c
      .addr __runtime__ 
      .byte flags
      .addr __next_entry__
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

.macro IPROC name, label, q
  .scope
    DEF_PROC = 1
    GenericEntry vocab::is_immediate, name, label, q
.endmacro

.macro PROC name, label, q
  .scope
    DEF_PROC = 1
    GenericEntry 0, name, label, q
.endmacro

.macro DEF name, label, q
  .scope
    DEF_RUN = 1
    GenericEntry 0, name, label, q
    DOCOL
.endmacro

.macro IDEF name, label, q
  .scope
    DEF_RUN = 1
    GenericEntry vocab::is_immediate, name, label, q
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
      ;NEXT
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

