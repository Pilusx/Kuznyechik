.include "common.s"

.text
.globl main
main:
    # call   read_block
    # R      %xmm0
    
    # TODO
    mov  $171, %rax
    movq %rax, %xmm0
    mov  $200, %rax
    movq %rax, %xmm1
    call kuznyechik_multiplication

    movq   %rax, %xmm0
    call   write_block
    jmp    exit
