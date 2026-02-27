default rel
extern ExitProcess
section .data
    nums dd 27, 14
section .text
    global _start
_start:
    sub rsp, 40

    mov eax, [nums]
    mov ecx, [nums + 4]

    cmp eax, ecx ; A - B
    jl DONE
MOVEAX:
    mov ecx, eax
DONE:
    call ExitProcess
