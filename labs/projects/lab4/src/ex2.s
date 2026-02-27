extern ExitProcess
default rel

section .data
    sum dd 0
    x dd 1
    end dd 10

section .text
   global main

main:
    sub rsp, 40 ;; 4 bytes for 4 args + 8 for alignment
    jmp TEST
LOOP:
    mov eax, [sum]
    add eax, [x]
    mov [sum], eax
    inc [x]
TEST:
    mov eax, [x]
    cmp eax, [end]
    jl LOOP
EXIT:
    mov ecx, [sum]
    call ExitProcess
