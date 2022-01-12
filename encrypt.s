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

    # Encrypt the block.
    jmp exit

    # Write it to stdout and loop.
    call write_block
    jmp  encrypt

# vim: ft=asm
