default rel
extern ExitProcess

section .data
    num dd 99

section .text
    global main

main:
    sub rsp, 40

    mov ecx, [num]

    call CLAMP

    mov ecx, eax
    call ExitProcess

CLAMP:
    push rbp
    mov rbp, rsp

    mov eax, ecx

    cmp eax, 100
    jg HUNDR

    cmp eax, 0
    js ZERO

DONE:
    mov rsp, rbp
    pop rbp
    ret

HUNDR:
    mov eax, 100
    jmp DONE

ZERO:
    mov eax, 0
    jmp DONE
