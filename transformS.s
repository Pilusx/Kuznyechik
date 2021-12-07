.include "common.s"

.text
.globl main
main:
    call   read_block
    # Endianness does not matter...
    S      %xmm0
    call   write_block
    jmp    exit
