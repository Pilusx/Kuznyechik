.include "common.s"

.text
.globl main

.macro test_kuznyechik_multiplication A B C
    mov \A, %rax
    mov \B, %rbx
    movq %rax, %xmm0
    movq %rbx, %xmm1
    call kuznyechik_multiplication
    call kuznyechik_reduce
    cmp \C, %rax
    jne end
    inc %r9
.endm

main:
    xor %r9, %r9
    
    # 22 Random tests.
    test_kuznyechik_multiplication $200, $171, $74
    test_kuznyechik_multiplication $451, $1, $0
    test_kuznyechik_multiplication $187, $136, $149
    test_kuznyechik_multiplication $32, $246, $181
    test_kuznyechik_multiplication $105, $128, $189
    test_kuznyechik_multiplication $68, $119, $44
    test_kuznyechik_multiplication $83, $60, $217
    test_kuznyechik_multiplication $26, $30, $239
    test_kuznyechik_multiplication $215, $252, $30
    test_kuznyechik_multiplication $216, $189, $227
    test_kuznyechik_multiplication $16, $149, $68
    test_kuznyechik_multiplication $79, $30, $38
    test_kuznyechik_multiplication $126, $198, $157
    test_kuznyechik_multiplication $243, $115, $2
    test_kuznyechik_multiplication $162, $21, $221
    test_kuznyechik_multiplication $84, $125, $29
    test_kuznyechik_multiplication $176, $70, $161
    test_kuznyechik_multiplication $1, $10, $10
    test_kuznyechik_multiplication $113, $108, $65
    test_kuznyechik_multiplication $57, $80, $78
    test_kuznyechik_multiplication $105, $190, $39
    test_kuznyechik_multiplication $58, $87, $24

end:
    pxor %xmm0, %xmm0

    movq %r9, %xmm0
    call write_block
    cmp $22, %r9
    jne assert_failed

    jmp exit
