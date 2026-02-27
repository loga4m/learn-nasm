; ### L5: Sum of Even Elements
; Array: `arr dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10`
; Sum only the even elements. Exit with result.
; Expected: 30.

default rel;
extern ExitProcess

section .data
    arr dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    size dd 10

section .text
    global main

main:
    sub rsp, 40

    mov ecx, arr
    mov edx, [size]

    call IsEven

    mov ecx, eax
    call ExitProcess

SumEven:
    push rbp
    mov rbp, rsp

    ;; save args
    mov DWORD [rbp + 2*8 + 2*8], edx ;; size
    mov DWORD [rbp + 1*8 + 2*8], ecx ;; arr addr

    xor eax, eax ;; return sum
    xor r8d, r8d ;; i = 0


TEST_EXPR:
    cmp r8d, edx
    jge DONE

LOOP:
    push DWORD eax
    sub rsp, 40
    mov ecx, [rbp + 1*8 + 8 + r8d*4]
    call IsEven


DONE:
    mov rsp, rbp
    pop rbp
    ret

IsEven:
    ;; 1 -- true
    ;; 0 -- false
    push rbp
    mov rbp, rsp

    xor eax, eax
    push QWORD 1

    test ecx, 0x1
    cmovz eax, [rsp]

    add rsp, 8

    mov rsp, rbp
    pop rbp
    ret
