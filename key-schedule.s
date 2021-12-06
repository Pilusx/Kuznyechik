# Encrypts data with Kuznyechik.

.include "common.s"

.text
.globl main
main:
    # Read the user key from stdin into %xmm5.
    #
    # It serves as the zeroth round key and also the seed
    # (in %xmm0) for the key expansion procedure.
    call   read_block
    movaps %xmm0, %xmm5
    call   read_block
    movaps %xmm0, %xmm6

    # Compute an encryption key schedule.

    key_generate 0 %xmm5 %xmm6 %xmm7 %xmm8
    key_generate 8 %xmm7 %xmm8 %xmm9 %xmm10
    key_generate 16 %xmm9 %xmm10 %xmm11 %xmm12
    key_generate 24 %xmm12 %xmm13 %xmm14 %xmm15

    # Print the keys
    movaps %xmm5, %xmm0
    call   write_block
    movaps %xmm6, %xmm0
    call   write_block
    movaps %xmm7, %xmm0
    call   write_block
    movaps %xmm8, %xmm0
    call   write_block
    movaps %xmm9, %xmm0
    call   write_block
    movaps %xmm10, %xmm0
    call   write_block
    movaps %xmm11, %xmm0
    call   write_block
    movaps %xmm12, %xmm0
    call   write_block
    movaps %xmm13, %xmm0
    call   write_block
    movaps %xmm14, %xmm0
    call   write_block

    # Exit
    jmp exit



# vim: ft=asm
