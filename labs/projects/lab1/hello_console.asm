default rel         

%define NULL 0
%define STD_OUTPUT_HANDLE -11

extern GetStdHandle        
extern WriteFile            
extern ExitProcess          

section .data
    message db "Hello from NASM on Windows x64!", 13, 10
    msg_len equ $ - message ; length in bytes (computed by NASM)

section .bss
    bytes_written resd 1    ; DWORD storage for WriteFile's output count

section .text
global _start
_start:
    ; Win64 ABI requirement: reserve 32-byte shadow space before calls
    ; + keep stack aligned. (40 = 32 + 8)
    sub rsp, 40

    ; GetStdHandle(STD_OUTPUT_HANDLE)
    mov ecx, STD_OUTPUT_HANDLE
    call GetStdHandle        ; RAX = stdout handle

    
    mov rcx, rax             ; arg1: hFile
    lea rdx, [message]       ; arg2: pointer to bytes
    mov r8d, msg_len         ; arg3: byte count
    lea r9,  [bytes_written] ; arg4: pointer to DWORD result
    mov qword [rsp+32], NULL ; arg5 on stack (after shadow): lpOverlapped = NULL
    call WriteFile

    ; ExitProcess(0)
    xor ecx, ecx
    call ExitProcess
