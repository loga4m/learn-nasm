extern ExitProcess
default rel

section .text
    global main

main:
    sub rsp, 40 ;; 4 bytes for 4 args + 8 for alignment

    mov eax, 10
    jmp LOOP

LOOP:
    sub eax, 3
TEST:
    test eax, eax
