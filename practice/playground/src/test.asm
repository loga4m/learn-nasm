default rel
extern ExitProcess

section .data
    garbage_5_aligner dd 723 ;; let's use positive integer as
                             ;; we shall pass it to ExitProcess, which accepts unsignd integer

section .text
    global main

main:
    sub rsp, 40

    ; Stack:
    ;  | arg 4     |
    ;  | arg 3     |
    ;  | arg 2     |
    ;  | arg 1     |
    ;  | alignment |___rsp

    ; I will write garbage value to alignment bytes
    ; so that I can check those bytes are indeed
    ; just for the sake of alignment

    mov eax, [garbage_5_aligner]
    mov [rsp], rax

    ; Stack:
    ;  | arg 4     |
    ;  | arg 3     |
    ;  | arg 2     |
    ;  | arg 1     |
    ;  | -23       |___rsp

    mov qword [rsp + 8], 232 ;; let's set arg 1 a value

    call DUMMY ;;  here, the RIP contains 0x543 (the addr of next instruction)
               ;;  after call, [RIP] is written to stack

    ; Stack:
    ;  | arg 4     |
    ;  | arg 3     |
    ;  | arg 2     |
    ;  | 232       |
    ;  | -23       |
    ;  | 0x543     |___rsp

    ;; the function returns value at eax.
    mov ecx, eax ;; assume the address of this instruction is 0x543
    call ExitProcess

DUMMY:
    push rbp ;; tmp = rbp => rsp -= 8 => write tmp to [rsp]
    mov rbp, rsp

    ; Stack:
    ;  | arg 4       |
    ;  | arg 3       |
    ;  | arg 2       |
    ;  | 232         |
    ;  | -23         |
    ;  | 0x543       |
    ;  | old_rbp_val |___rsp
    ;
    ; Now: rbp = rsp

    ;; Access alignment bytes. If hypothesis is correct, we get -23 on rax
    mov eax, [rsp + 8 * 2] ;; add 8, you get 0x543. Add 16 you are at the start address of -23

    ;; You can also test: Access arg 1
    ; mov rax, [rsp + 8 * 3]

    mov rsp, rbp
    pop rbp ;; rbp = 8 bytes from [rsp]; rsp += 8

    ; Stack:
    ;  | arg 4       |
    ;  | arg 3       |
    ;  | arg 2       |
    ;  | 232         |
    ;  | -23         |
    ;  | 0x543       |___rsp :=> now here! At return addr.
    ;  | old_rbp_val |
    ;
    ; Now: rbp = old_rbp_val

    ret ;; => mov rip, [rsp]; rsp += 8

    ; Stack:
    ;  | arg 4       |
    ;  | arg 3       |
    ;  | arg 2       |
    ;  | 232         |
    ;  | -23         |___rsp
    ;  | 0x543       |
    ;  | old_rbp_val |


;; Check program result:
; 1. Run
; 2. Check either $ERRORLEVEL$ or $LASTEXITCODE$
