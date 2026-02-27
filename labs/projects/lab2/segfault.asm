default rel

section .text
	global _start
	extern ExitProcess

_start:
	mov rax, 0x0
	mov dword [rax], 0x1

	xor rax, rax
	call ExitProcess
