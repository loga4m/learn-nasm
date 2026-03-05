default rel
extern ExitProcess

section .data
    nums dd -121, 222

section .text
    global main

main:
    sub rsp, 40

    mov ecx, [nums]
    mov edx, [nums + 4]

    mov [rsp + 4 * 8], edx
    mov [rsp + 3 * 8], ecx

    call MIN

    mov ecx, eax

    call ExitProcess

MIN:
    push rbp ; tmp = rbp; rsp -= 8; write tmp to [rsp];
    mov rbp, rsp

    mov eax, [rsp + 6 * 8]
    cmp [rsp + 5 * 8], eax
    cmovl eax, [rsp + 5 * 8]

    mov rsp, rbp
    pop rbp
    ret
