; ### L1: Sum of Array
; Array in `.data`: `arr dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10`
; Sum all elements. Store result in `ecx`. Exit.
; Expected: 55.

; **Hint:** Use a counter register and `lea` or indexed addressing like `[arr + rsi*4]`.

default rel
extern ExitProcess

section .data
    arr dd 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ;; first element: size

section .text
    global main

main:
    sub rsp, 40

    mov rcx, arr ; address of array

    call SumArray

    mov ecx, eax
    call ExitProcess

SumArray:
    push rbp
    mov rbp, rsp

    xor eax, eax ;; sum storage
    xor r8d, r8d ;; counter
    mov edx, [ecx] ;; array size
    add ecx, 4 ;; skip size and move to data

TEST_EXPR:
    cmp r8d, edx
    jge DONE ;; if i >= edx, we're done

LOOP:
    lea r9d, [ecx + r8d*4] ;; Get address of current element
    add eax, [r9d] ;; Copy value of current element
    inc r8d ;; i++
    jmp TEST_EXPR

DONE:
    mov rsp, rbp
    pop rbp
    ret
