default rel

section .data
    op dd 3

section .bss
    result resd 1

section .text
    global _start

extern ExitProcess

_start:
    sub rsp, 40
    cmp dword [op], 1
    je C1
    cmp dword [op], 2
    je C2
    cmp dword [op], 3
    je C3
    cmp dword [op], 4
    je C4
    jmp DEF
C1:
    mov dword [result], 10
    jmp exit
C2:
    mov dword [result], 20
    jmp exit
C3:
    mov dword [result], 30
    jmp exit
C4:
    mov dword [result], 40
    jmp exit
DEF:
    mov dword [result], 0
exit:
    mov ecx, [result]
    call ExitProcess
