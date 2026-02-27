; ### L4: Count Until Condition
; Starting from `eax = 1`, keep doubling (`shl eax, 1`) and count iterations until `eax` exceeds 1000. Exit with the iteration count.
; Expected: 10.
; (This is a direct extension of the `for_loop.asm` tutorial — make sure you understand that one first.)

default rel
extern ExitProcess

section .data
    start_num dd 1
    up_bound dd 1000

section .text
    global main

main:
    sub rsp, 40

    mov ecx, [start_num]
    mov edx, [up_bound]

    call CountUntilUpBound

    mov ecx, eax
    call ExitProcess

CountUntilUpBound:
    push rbp
    mov rbp, rsp

    xor eax, eax ;; counter/result

TEST_EXPR:
    cmp ecx, edx
    jg DONE

LOOP:
    shl ecx, 1
    inc eax
    jmp TEST_EXPR

DONE:
    mov rsp, rbp
    pop rbp
    ret
