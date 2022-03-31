.macro GenericEntry id, name, label, payload
  .scope
    ::.ident (.string(name))=entry 
    entry:
      .byte id
      .addr __runtime__ 
      .addr __next_entry__
      .ifblank payload 
        .byte payload $0
      .else
        .byte payload
      .endif
      .addr __compile__
      .addr __list__
      .ifblank label
        .asciiz .string(name)
      .else
        .asciiz label
      .endif
    __runtime__:
  .endscope
.endmacro

.macro rEntry name, label
  GenericEntry bytecode::GTO, name, label,0
.endmacro

.macro jEntry name, label, payload
  GenericEntry bytecode::NAT, name, label,0
.endmacro

.macro cEntry name, label,payload
  GenericEntry bytecode::NAT, name, label, payload
.endmacro


.macro CMD name, label,payload
  .scope
    DEF_CMD = 1
    cEntry name, label,payload
.endmacro

.macro PROC name, label
  .scope
    DEF_PROC = 1
    jEntry name, label
.endmacro

.macro DEF name, label
  .scope
    DEF_RUN = 1
    rEntry name, label
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

.macro DATA
  .ifdef DEF_RUN
    rRet
  .endif
  data:
.endmacro

.macro END name, label
    .ifdef DEF_RUN 
      .ifndef data
        .ifndef __compile__
          rRet
        .endif
      .endif
    .elseif .def (DEF_PROC)
    .endif
    .ifndef __compile__
      __compile__ = compiler::write_run ; default compiler
    .endif
    .ifndef __list__
      __list__ = runtime::list_entry ; default lister
    .endif
    .ifndef __next_entry__
      __next_entry__:
    .endif
  .endScope
.endmacro