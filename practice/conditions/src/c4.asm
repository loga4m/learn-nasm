; ### c4: even or odd
; `eax = 7`. if even store `0` in `ecx`, if odd store `1`. exit with `ecx`.
; **Hint:** `test eax, 1` checks the lowest bit.
; Expected: 1.

default rel
extern ExitProcess

section .data
    num dd -120
section .text
    global main

main:
    sub rsp, 40

    mov ecx, [num]

    call IsEven

    mov ecx, eax
    call ExitProcess

IsEven:
    push rbp
    mov rbp, rsp

    mov eax, 1
    xor edx, edx

    test ecx, 0x1 ;; eax & 0x1

    cmovz eax, edx ;; if test result is zero, the number is even

    mov rsp, rbp
    pop rbp
    ret
