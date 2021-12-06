.include "common.s"

.text
.globl main
main:
    call   read_block
    S      %xmm0
    call   write_block
    jmp    exit
