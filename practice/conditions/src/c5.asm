; ### C5: Max of Three
; `eax = 10`, `ebx = 35`, `ecx = 22`. Store the largest in `edx`. Exit with `edx`.
; Expected: 35.

default rel
extern ExitProcess

section .data
    nums dd 50, 35, 22

section .text
    global main

main:
    sub rsp, 40

    mov ecx, [nums]
    mov edx, [nums + 1*4]
    mov r8d, [nums + 2*4]

    call MaxOfThree

    mov ecx, eax
    call ExitProcess

MaxOfThree:
    push rbp
    mov rbp, rsp

    mov eax, ecx
    cmp eax, edx
    cmovl eax, edx
    cmp eax, r8d
    cmovl eax, r8d

    mov rsp, rbp
    pop rbp
    ret
