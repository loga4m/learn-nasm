default rel
extern ExitProcess

section .data
    nums dd -10, 10

section .text
    global main

main:
    sub rsp, 40

    mov ecx, [nums]
    mov edx, [nums + 4]

    call MIN

    mov ecx, eax

    call ExitProcess

MIN:
    push rbp ; tmp = rbp; rsp -= 8; write tmp to [rsp];
    mov rbp, rsp

    mov eax, edx
    cmp ecx, edx
    cmovl eax, ecx

    mov rsp, rbp
    pop rbp
    ret

MAX:
    push rbp
    mov rbp, rsp

    mov eax, edx
    cmp ecx, edx
    cmovg eax, ecx

    mov rsp, rbp
    pop rbp
    ret
