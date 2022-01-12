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

    key_generate %xmm5 %xmm6 %xmm7 %xmm8 %xmm9 %xmm10 %xmm11 %xmm12 %xmm13 %xmm14


encrypt:
    # Try to read a block of plaintext.
    # Exit on EOF.
    call read_block

    round %xmm5
    round %xmm6
    round %xmm7
    round %xmm8
    round %xmm9
    round %xmm10
    round %xmm11
    round %xmm12
    round %xmm13

    xorps %xmm14, %xmm0
    call write_block
    

# vim: ft=asm
