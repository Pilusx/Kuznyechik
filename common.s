.data
    # A 16-byte, 16-byte-aligned buffer, used to transfer
    # data between stdin/stdout and XMM registers.
    .comm buf, 16, 16


    pi:
    .byte 252, 238, 221, 17, 207, 110, 49, 22, 251, 196, 250, 218, 35, 197, 4, 77 
    .byte 233, 119, 240, 219, 147, 46, 153, 186, 23, 54, 241, 187, 20, 205, 95, 193
    .byte 249, 24, 101, 90, 226, 92, 239, 33, 129, 28, 60, 66, 139, 1, 142, 79
    .byte 5, 132, 2, 174, 227, 106, 143, 160, 6, 11, 237, 152, 127, 212, 211, 31
    .byte 235, 52, 44, 81, 234, 200, 72, 171, 242, 42, 104, 162, 253, 58, 206, 204
    .byte 181, 112, 14, 86, 8, 12, 118, 18, 191, 114, 19, 71, 156, 183, 93, 135
    .byte 21, 161, 150, 41, 16, 123, 154, 199, 243, 145, 120, 111, 157, 158, 178, 177
    .byte 50, 117, 25, 61, 255, 53, 138, 126, 109, 84, 198, 128, 195, 189, 13, 87
    .byte 223, 245, 36, 169, 62, 168, 67, 201, 215, 121, 214, 246, 124, 34, 185, 3
    .byte 224, 15, 236, 222, 122, 148, 176, 188, 220, 232, 40, 80, 78, 51, 10, 74
    .byte 167, 151, 96, 115, 30, 0, 98, 68, 26, 184, 56, 130, 100, 159, 38, 65
    .byte 173, 69, 70, 146, 39, 94, 85, 47, 140, 163, 165, 125, 105, 213, 149, 59
    .byte 7, 88, 179, 64, 134, 172, 29, 247, 48, 55, 107, 228, 136, 217, 231, 137
    .byte 225, 27, 131, 73, 76, 63, 248, 254, 141, 83, 170, 144, 202, 216, 133, 97
    .byte 32, 113, 103, 164, 45, 43, 9, 91, 203, 155, 37, 208, 190, 229, 108, 82
    .byte 89, 166, 116, 210, 230, 244, 180, 192, 209, 102, 175, 194, 57, 75, 99, 182
    
    pi_inv:
    .byte 165, 45, 50, 143, 14, 48, 56, 192, 84, 230, 158, 57, 85, 126, 82, 145
    .byte 100, 3, 87, 90, 28, 96, 7, 24, 33, 114, 168, 209, 41, 198, 164, 63
    .byte 224, 39, 141, 12, 130, 234, 174, 180, 154, 99, 73, 229, 66, 228, 21, 183
    .byte 200, 6, 112, 157, 65, 117, 25, 201, 170, 252, 77, 191, 42, 115, 132, 213
    .byte 195, 175, 43, 134, 167, 177, 178, 91, 70, 211, 159, 253, 212, 15, 156, 47
    .byte 155, 67, 239, 217, 121, 182, 83, 127, 193, 240, 35, 231, 37, 94, 181, 30
    .byte 162, 223, 166, 254, 172, 34, 249, 226, 74, 188, 53, 202, 238, 120, 5, 107
    .byte 81, 225, 89, 163, 242, 113, 86, 17, 106, 137, 148, 101, 140, 187, 119, 60
    .byte 123, 40, 171, 210, 49, 222, 196, 95, 204, 207, 118, 44, 184, 216, 46, 54
    .byte 219, 105, 179, 20, 149, 190, 98, 161, 59, 22, 102, 233, 92, 108, 109, 173
    .byte 55, 97, 75, 185, 227, 186, 241, 160, 133, 131, 218, 71, 197, 176, 51, 250
    .byte 150, 111, 110, 194, 246, 80, 255, 93, 169, 142, 23, 27, 151, 125, 236, 88
    .byte 247, 31, 251, 124, 9, 13, 122, 103, 69, 135, 220, 232, 79, 29, 78, 4
    .byte 235, 248, 243, 62, 61, 189, 138, 136, 221, 205, 11, 19, 152, 2, 147, 128
    .byte 144, 208, 36, 52, 203, 237, 244, 206, 153, 16, 68, 64, 146, 58, 1, 38
    .byte 18, 26, 72, 104, 245, 129, 139, 199, 214, 32, 10, 8, 0, 76, 215, 116

    lambda:
    .byte 1, 148, 32, 133, 16, 194, 192, 1, 251, 1, 192, 194, 16, 133, 32, 148

    order:
    .byte 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

    # p(x) = x^8 + x^7 + x^6 + x + 1
    # 451 = '111000011'
    poly:
    .word 451

.text

# Make a Linux syscall.
.macro linux_syscall NR ARG1 ARG2 ARG3
    mov \NR,   %rax
    mov \ARG1, %rdi
.ifnb \ARG2
    mov \ARG2, %rsi
.ifnb \ARG3
    mov \ARG3, %rdx
.endif
.endif
    syscall
.endm

# Syscall numbers.
.equ NR_read,   0
.equ NR_write,  1
.equ NR_exit,  60

# Read 16 bytes from stdin to %xmm0.
read_block:
    linux_syscall $NR_read, $0, $buf, $16
    movaps buf, %xmm0
    ret

# Write 16 bytes from %xmm0 to stdout.
write_block:
    movaps %xmm0, buf
    linux_syscall $NR_write, $1, $buf, $16
    ret

change_endianness:
    # Input: xmm0
    # Output: xmm0
    # Modifies xmm1
    # Changes endianness of xmm0: little <-> big
    movups order, %xmm1
    pshufb %xmm1, %xmm0 # Change to little endian.
    ret

exit:
    # Call _exit(0).
    linux_syscall $NR_exit, $0

assert_failed:
    # Call _exit(1)
    linux_syscall $NR_exit, $1

.macro key_generate i K1 K2 K3 K4
    # TODO
    movaps \K1, \K3
    movaps \K2, \K4
.endm

.macro S_partial i P X
    # Uses rax, and register X.
    pextrb \i, \X, %rax          # save ith-byte of X to rax
    mov \P(%rax), %rax           # al = pi[index]
    pinsrb \i, %rax, \X          # save the rbx to the ith-byte of X 
.endm

.macro S_builder P X
    # Input:  X 128-bits
    S_partial $0 \P \X
    S_partial $1 \P \X
    S_partial $2 \P \X
    S_partial $3 \P \X
    S_partial $4 \P \X
    S_partial $5 \P \X
    S_partial $6 \P \X
    S_partial $7 \P \X
    S_partial $8 \P \X
    S_partial $9 \P \X
    S_partial $10 \P \X
    S_partial $11 \P \X
    S_partial $12 \P \X
    S_partial $13 \P \X
    S_partial $14 \P \X
    S_partial $15 \P \X
.endm

.macro S X
    # X = S(X)
    # Modifies rax.
    S_builder pi \X
.endm

.macro S_inv X
    S_builder pi_inv \X
.endm

kuznyechik_multiplication:
    # Input : lower 64-bits in xmm0 and xmm1
    # Output: 64-bits in rax
    # Modifies xmm0
    pclmulqdq  $0, %xmm1, %xmm0   # Polynomial mulitplication in GF(2)[x]/x^128
    pextrw     $0, %xmm0, %rax    # Extract 16-bit result to %ax
    ret

kuznyechik_reduce:
    # Reduces the final result (mod p(x))
    # Input: Polynomial encoded in 16bits - ax
    # Output: Reduced polynomial encoded in 8 bits - al
    # Modifies rax, rbx, rcx.
    # Pseudocode:
    # b = 2**7 * poly
    # c = 2**15
    # while c >= 2**8:
    #    if a & c:
    #       a = a ^ b
    #    b = b >> 1
    #    c = c >> 1
    # return a

    mov    poly, %rbx             # rbx = p(x) = 451
    sal    $7,   %rbx             # rbx = 2^7 p(x)
    mov    $32768, %rcx           # rcx = 2^15 = 128

    # Loop n = 7 ... 0
reduce_loop:
    test   %rax, %rcx             # rax & 2^(n + 8)
    jz     continue_loop
    xor    %rbx, %rax             # rax = rax xor rbx
continue_loop:
    sar    $1, %rbx               # rbx = 2^(n-1) p(x)
    sar    $1, %rcx               # rcx = 2^(n+7)
    cmp    $256, %rcx             # rcx >= 2^8  => Next iteration
    jge    reduce_loop
    
    ret

.macro kuznyechik_linear_functional_step i
    pxor   %xmm0, %xmm0
    pextrb \i, %xmm2, %rax    # save ith-byte of xmm2 to rax
    pinsrb $0, %rax, %xmm0
    mov    \i, %rax           # rax = i
    mov    lambda(%rax), %rax # rax = lambda[rax] = lambda[i]
    pinsrb $0, %rax, %xmm1
    call   kuznyechik_multiplication
    xor    %rax, %rbx         # Store the partial result. (kuznyechik_add)
.endm

kuznyechik_linear_functional:
    # Input: xmm2 - 128bit value (16 parts)
    # Output: al - 8bit result
    # Modifies xmm0, xmm1, rax, rbx, rcx.
    # Pseudocode:
    # b = 0
    # for i in range(16):
    #    a = kuznyechik_multiplication(lambda[i], X[i])
    #    b = a xor b    # kuznyechik_add
    # a = b
    # a = kuznyechik_reduce(a)
    # return a

    xor    %rbx, %rbx
    pxor   %xmm1, %xmm1
    kuznyechik_linear_functional_step $0
    kuznyechik_linear_functional_step $1
    kuznyechik_linear_functional_step $2
    kuznyechik_linear_functional_step $3
    kuznyechik_linear_functional_step $4
    kuznyechik_linear_functional_step $5
    kuznyechik_linear_functional_step $6
    kuznyechik_linear_functional_step $7
    kuznyechik_linear_functional_step $8
    kuznyechik_linear_functional_step $9
    kuznyechik_linear_functional_step $10
    kuznyechik_linear_functional_step $11
    kuznyechik_linear_functional_step $12
    kuznyechik_linear_functional_step $13
    kuznyechik_linear_functional_step $14
    kuznyechik_linear_functional_step $15

    mov    %rbx, %rax
    call   kuznyechik_reduce
    ret

transform_R:
    # Input: xmm2
    # Modifies xmm0, xmm1, rax, rbx, rcx.
    # Output: xmm2
    call kuznyechik_linear_functional
    psrldq $1, %xmm2             # xmm2 = (xmm2 >> 1)
    pinsrb $15, %rax, %xmm2      # save the result to the 15th-byte of xmm2
    ret

transform_R_inv:
    # Input: xmm2
    # Modifies xmm0, xmm1, rax, rbx, rcx.
    # Output: xmm2
    pextrb $15, %xmm2, %rax
    pslldq $1, %xmm2             # xmm2 = (xmm2 << 1)
    pinsrb $0, %rax, %xmm2       # xmm2 = xmm2 + al
    call kuznyechik_linear_functional
    pinsrb $0, %rax, %xmm2       # save the result to the 0th byte of xmm2
    ret


transform_L:
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    call transform_R
    ret

transform_L_inv:
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
    call transform_R_inv
