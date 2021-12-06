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
    .byte 148, 32, 133, 16, 194, 192, 1, 251, 1, 192, 194, 16, 133, 32, 148, 1

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
    mov \P(%rax), %rax           # ax = pi[index]
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
    S_builder pi \X
.endm

.macro S_inv X
    S_builder pi_inv \X
.endm
