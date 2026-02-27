; ### L3: Find Maximum in Array
; Array: `arr dd 4, 17, 2, 99, 31, 8`
; Find the maximum element. Exit with it.
; Expected: 99.

default rel
extern ExitProcess

section .data
    size dd 6
    arr dd 4, 17, 2, 99, 31, 8

section .text
    global main

main:
    sub rsp, 40

    mov ecx, arr
    mov edx, [size]

    call Max

    mov ecx, eax
    call ExitProcess

; Max
; @params
;   ecx     arr_address,
;   edx     arr_size
; @returns
;   eax     maximum value in arr

Max:
    push rbp
    mov rbp, rsp

    mov eax, [ecx] ;; set max elem = arr[0]
    xor r8d, r8d ;; loop counter: i = 0

TEST_EXPR:
    cmp r8d, edx
    jge DONE

LOOP:
    mov r9d, [arr + r8d * 4]
    cmp r9d, eax
    cmovg eax, r9d
    inc r8d
    jmp TEST_EXPR

DONE:
    mov rsp, rbp
    pop rbp
    ret
