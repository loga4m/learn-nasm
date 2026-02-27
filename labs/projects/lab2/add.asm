; add.asm (Win64, NASM + GoLink)
;nasm -f win64 add.asm -o add.obj
;golink /console /entry _start add.obj kernel32.dll /fo add.exe
default rel

extern ExitProcess

section .bss
    
section .data 
  
section .text
    global _start
    global IntegerAaddSub_

; -------------------------
; Program entry point
; -------------------------
_start:
    sub rsp, 40          ; 32-byte shadow space + alignment (Win64 ABI)

    ; TODO Put test values into arg registers (a,b,c,d)
    ; a=10, b=20, c=30, d=18
    ; 10+20+30 - 18 = 60 - 18 = 42

    mov ecx, 10
    mov edx, 20
    mov r8d, 30
    mov r9d, 18

    call IntegerAddSub_  ; EAX = a + b + c - d  (should be 42)
  
    mov ecx, eax         ; ExitProcess(exit_code = result)
    call ExitProcess     ; end program

; -------------------------
; int IntegerAddSub_(int a,int b,int c,int d)
; a=ECX, b=EDX, c=R8D, d=R9D, return EAX
; ------------------------- EAX = a + b + c - d  
IntegerAddSub_:  
    ;  TODO

    mov eax, ecx
    add eax, edx
    add eax, r8d
    sub eax, r9d
    
    ret