default rel
extern ExitProcess

section .data
    num dd -1

section .text
    global main

main:
    sub rsp, 40 ;; 4 args = 32; + 8 for alignment

    mov ecx, [num]
    call SIGN_DETECT ;; subs 8 resulting in total sub of 48 so far => aligned
    mov ecx, eax

    call ExitProcess

SIGN_DETECT:
    push rbp ;; => tmp = rbp; rsp -= 8;
    mov rbp, rsp

    sub rsp, 12
    mov DWORD [rsp], 0
    mov DWORD [rsp + 4], 1
    mov DWORD [rsp + 2*4], 2

    mov eax, ecx

    test eax, eax

    cmovs eax, [rsp + 4]
    cmovns eax, [rsp + 2*4]
    cmovz eax, [rsp]

    add rsp, 12
    mov rsp, rbp
    pop rbp
    ret
