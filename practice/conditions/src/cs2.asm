default rel
extern ExitProcess

section .data
    num dd 0

section .text
    global main

main:
    sub rsp, 40

    mov eax, [num]

    test eax, eax

    jz ZERO
    js NEG
    jmp POS

DONE:
    mov ecx, eax
    call ExitProcess

ZERO:
    mov eax, 0
    jmp DONE
NEG:
    mov eax, 1
    jmp DONE
POS:
    mov eax, 2
    jmp DONE
