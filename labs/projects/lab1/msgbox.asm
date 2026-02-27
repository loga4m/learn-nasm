default rel

%define NULL 0
%define MB_YESNO      0x00000004
%define MB_DEFBUTTON2 0x00000100
%define IDNO          7

extern MessageBoxA     
extern ExitProcess     

section .data
    text db "Hello from MessageBox!", 0
    cap  db "MessageBox", 0

section .text
global _start
_start:
    sub rsp, 40         ; shadow + alignment

.display:
    ; MessageBoxA(hWnd, lpText, lpCaption, uType)
    xor ecx, ecx                ; arg1: hWnd = NULL
    lea rdx, [text]             ; arg2: message text
    lea r8,  [cap]              ; arg3: caption
    mov r9d, MB_YESNO | MB_DEFBUTTON2 ; arg4: buttons + default
    call MessageBoxA

    ; If user clicks "No" (IDNO=7), show again
    cmp eax, IDNO
    je .display

    xor ecx, ecx
    call ExitProcess