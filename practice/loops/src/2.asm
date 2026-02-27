; ### L2: Count Negatives
; Array: `arr dd 3, -1, 7, -4, 0, -2, 5`
; Count how many elements are negative. Exit with count.
; Expected: 3.

default rel
extern ExitProcess

section .data
    arr dd 7, 3, -1, 7, -4, 0, -2, 5 ;; arr->size = first element

section .text
    global main

main:
    sub rsp, 40

    lea ecx, [arr + 4] ;; copy arr data values address for 1st arg
    mov edx, [arr] ;;  copy arr size

    call CountNegs

    mov ecx, eax
    call ExitProcess

CountNegs:
    push rbp
    mov rbp, rsp

    xor eax, eax ;; counter/return result
    xor r8d, r8d ;; loop counter

TEST_EXPR:
    cmp r8d, edx
    jge DONE

LOOP:
    mov r9d, [ecx + r8d * 4]
    test r9d, r9d
    jns CONTINUE
    inc eax
CONTINUE:
    inc r8d
    jmp TEST_EXPR

DONE:
    mov rsp, rbp
    pop rbp
    ret
