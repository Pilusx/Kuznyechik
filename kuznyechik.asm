; ----------------------------------------------------------------------------------------
; Useful links:
; https://cs.lmu.edu/~ray/notes/nasmtutorial/
; https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
; Runs on 64-bit Linux only.
; To assemble and run:
;
;   nasm -felf64 kuznyechik.asm && gcc -m64 -no-pie kuznyechik.o -o kuznyechik && ./kuznyechik
; ----------------------------------------------------------------------------------------

        section   .text
        global main
        extern printf

test_write_kuznyechik:
        mov       rax, 1                  ; system call for write
        mov       rdi, 1                  ; file handle 1 is stdout
        mov       rsi, message            ; address of string to output
        mov       rdx, 11                 ; number of bytes
        syscall                           ; invoke operating system to do the write
        ret

test_pi:
        xor       rcx, rcx                ; Reset rcx
print_pi:                                 ; Prints first 4 values of Pi
        push      rcx
        mov       rdi, pi_message         ; pass format string
        mov       rsi, rcx                ; pass the index
        xor       rax, rax                ; because printf is varargs
        xor       rdx, rdx                ; Reset rdx
        mov       dl, [pi+rcx]            ; ith value of pi
        call      printf                  ; external call
        pop       rcx
        inc       rcx
        cmp       rcx, 4
        jl        print_pi                ; Jump if counter is < 4
        ret

S_partial:
    ; Input:  rax: First 64-bits
    ; Output: rbx: Last 64-bits
        mov       rcx, 64                 ; 8 iterations
        xor       rbx, rbx                ; Reset rbx
S_loop:
        sub       rcx, 8                  ; We iterate 7...0
        mov       rdx, rax                ; Copy rax (x)
        shr       rdx, cl                 ; x >> (8 * i)
        and       rdx, 0xff               ; and (2^8 - 1)
        shl       rbx, 8                  ; rbx << 8
        mov       bl, [pi+rdx]            ; rbx + pi[index]
        cmp       rcx, 0
        jg        S_loop                  ; If rcx > 0 another iteration 
        ret
S:
    ; Input: rax: First 64-bits
    ; Input: rbx: Last 64-bits
    ; Output: rax: First 64-bits
    ; Output: rbx: Last 64-bits
        push      rbx                     ; Save last bits
        call      S_partial               ; New last 64-bits in rbx = Transformed first bits 
        pop       rax                     ; Get last bits
        push      rbx                     ; Save new last 64-bits
        call      S_partial               ; New first 64-bits in rbx = Transformed last bits
        mov       rax, rbx                ; Move first bits
        pop       rax                     ; Get new last bits
        ret

test_S:
    ; Input: rax: First 64-bits
    ; Input: rbx: Last 64-bits
        push      rax
        push      rbx
        mov       rdi, S_message          ; pass format string
        mov       rsi, rax                ; pass first 64-bits
        xor       rax, rax                ; because printf is varargs
        mov       rdx, rbx                ; second 64-bits
        call      printf                  ; external call

        pop       rbx
        pop       rax

        call      S
        push      rax
        push      rbx

        mov       rdi, S_message2         ; pass format string
        mov       rsi, rax                ; pass first 64-bits
        xor       rax, rax                ; because printf is varargs
        mov       rdx, rbx                ; second 64-bits
        call      printf                  ; external call
        
        pop       rbx
        pop       rax
        ret

test_multiple_S:
        mov       rax, 0xffeeddccbbaa9988 ; First bits
        mov       rbx, 0x1122334455667700 ; Last bits
        call      test_S
        mov       rcx, 0xb66cd8887d38e8d7;
        cmp       rax, rcx ;
        jne       assert_failed ;
        mov       rcx, 0x7765aeea0c9a7efc ;
        cmp       rbx, rcx ;
        jne       assert_failed ;
        call      test_S
        mov       rcx, 0x559d8dd7bd06cbfe ;
        cmp       rax, rcx;
        jne       assert_failed ;
        mov       rcx, 0x7e7b262523280d39 ;
        cmp       rbx, rcx ;
        jne       assert_failed ;
        call      test_S
        mov       rcx, 0x0c3322fed531e463 ;
        cmp       rax, rcx ;
        jne       assert_failed ;
        mov       rcx, 0x0d80ef5c5a81c50b ;
        cmp       rbx, rcx ;
        jne       assert_failed ;
        call      test_S
        mov       rcx, 0x23ae65633f842d29 ;
        cmp       rax, rcx ;
        jne       assert_failed ;
        mov       rcx, 0xc5df529c13f5acda ;
        cmp       rbx, rcx ;
        jne       assert_failed ;
        ret

main:
        call test_write_kuznyechik
        call test_pi
        call test_multiple_S
        jmp exit

assert_failed:
        mov       rax, 60                 ; system call for exit
        mov       rdi, 1                  ; exit code 1
        syscall  

exit:
        mov       rax, 60                 ; system call for exit
        xor       rdi, rdi                ; exit code 0
        syscall                           ; invoke operating system to exit

        section   .data

; Constants
message:
    db            "Kuznyechik", 10        ; note the newline at the end
pi_message: 
    db            "Pi[%d] = %d", 10, 0
S_message:
    db            "S(%.16llx %.16llx) = ", 0
S_message2:
    db            "%.16llx %.16llx", 10, 0
pi:
    db            252, 238, 221, 17, 207, 110, 49, 22, 251, 196, 250, 218, 35, 197, 4, 77, 
    db            233, 119, 240, 219, 147, 46, 153, 186, 23, 54, 241, 187, 20, 205, 95, 193, 
    db            249, 24, 101, 90, 226, 92, 239, 33, 129, 28, 60, 66, 139, 1, 142, 79, 
    db            5, 132, 2, 174, 227, 106, 143, 160, 6, 11, 237, 152, 127, 212, 211, 31, 
    db            235, 52, 44, 81, 234, 200, 72, 171, 242, 42, 104, 162, 253, 58, 206, 204, 
    db            181, 112, 14, 86, 8, 12, 118, 18, 191, 114, 19, 71, 156, 183, 93, 135, 
    db            21, 161, 150, 41, 16, 123, 154, 199, 243, 145, 120, 111, 157, 158, 178, 177,
    db            50, 117, 25, 61, 255, 53, 138, 126, 109, 84, 198, 128, 195, 189, 13, 87, 
    db            223, 245, 36, 169, 62, 168, 67, 201, 215, 121, 214, 246, 124, 34, 185, 3, 
    db            224, 15, 236, 222, 122, 148, 176, 188, 220, 232, 40, 80, 78, 51, 10, 74, 
    db            167, 151, 96, 115, 30, 0, 98, 68, 26, 184, 56, 130, 100, 159, 38, 65, 
    db            173, 69, 70, 146, 39, 94, 85, 47, 140, 163, 165, 125, 105, 213, 149, 59, 
    db            7, 88, 179, 64, 134, 172, 29, 247, 48, 55, 107, 228, 136, 217, 231, 137, 
    db            225, 27, 131, 73, 76, 63, 248, 254, 141, 83, 170, 144, 202, 216, 133, 97,
    db            32, 113, 103, 164, 45, 43, 9, 91, 203, 155, 37, 208, 190, 229, 108, 82, 
    db            89, 166, 116, 210, 230, 244, 180, 192, 209, 102, 175, 194, 57, 75, 99, 182
inv_pi:
    db            165, 45, 50, 143, 14, 48, 56, 192, 84, 230, 158, 57, 85, 126, 82, 145, 
    db            100, 3, 87, 90, 28, 96, 7, 24, 33, 114, 168, 209, 41, 198, 164, 63, 
    db            224, 39, 141, 12, 130, 234, 174, 180, 154, 99, 73, 229, 66, 228, 21, 183, 
    db            200, 6, 112, 157, 65, 117, 25, 201, 170, 252, 77, 191, 42, 115, 132, 213, 
    db            195, 175, 43, 134, 167, 177, 178, 91, 70, 211, 159, 253, 212, 15, 156, 47, 
    db            155, 67, 239, 217, 121, 182, 83, 127, 193, 240, 35, 231, 37, 94, 181, 30, 
    db            162, 223, 166, 254, 172, 34, 249, 226, 74, 188, 53, 202, 238, 120, 5, 107, 
    db            81, 225, 89, 163, 242, 113, 86, 17, 106, 137, 148, 101, 140, 187, 119, 60, 
    db            123, 40, 171, 210, 49, 222, 196, 95, 204, 207, 118, 44, 184, 216, 46, 54, 
    db            219, 105, 179, 20, 149, 190, 98, 161, 59, 22, 102, 233, 92, 108, 109, 173, 
    db            55, 97, 75, 185, 227, 186, 241, 160, 133, 131, 218, 71, 197, 176, 51, 250,
    db            150, 111, 110, 194, 246, 80, 255, 93, 169, 142, 23, 27, 151, 125, 236, 88, 
    db            247, 31, 251, 124, 9, 13, 122, 103, 69, 135, 220, 232, 79, 29, 78, 4, 
    db            235, 248, 243, 62, 61, 189, 138, 136, 221, 205, 11, 19, 152, 2, 147, 128, 
    db            144, 208, 36, 52, 203, 237, 244, 206, 153, 16, 68, 64, 146, 58, 1, 38, 
    db            18, 26, 72, 104, 245, 129, 139, 199, 214, 32, 10, 8, 0, 76, 215, 116
