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
    cmp  $16, %rax
    jl   exit

    inverse_round %xmm14
    inverse_round %xmm13
    inverse_round %xmm12
    inverse_round %xmm11
    inverse_round %xmm10
    inverse_round %xmm9
    inverse_round %xmm8
    inverse_round %xmm7
    inverse_round %xmm6

    xorps %xmm5, %xmm0
    call write_block
    jmp  encrypt  

# vim: ft=asm
