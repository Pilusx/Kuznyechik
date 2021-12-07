.include "common.s"

.text
.globl main
main:
    call   read_block # Reads bytes in the big endian order.
    call   change_endianness # Change to little endian.

    movaps %xmm0, %xmm2
    call   transform_R
    movaps %xmm2, %xmm0

    call   change_endianness # Change to big endian.
    call   write_block
    jmp    exit
