.section .rodata

msg:
	.string "Hello World\n"
	.equ msgSz,.-msg-1

prompt: 
	.string "What is your name: "
	.equ promptSz,.-promptSz

prompt2:
	.string "Your name is: "
	.equ prompt2Sz,.-prompt2Sz 

	.text
	.globl _start

_start:
	pushq %rsp
	movq %rsp, %rbp

	movl $msgSz, %edx
	movl $msg, %esi
	movl $1, %edi
	movl $1, %eax
	syscall

	movl $promptSz, %edx
	movl $prompt, %esi
	movl $1, %edi
	movl $1, %eax
	syscall


	movq %rbp, %rsp
	popq %rbp
	movl $60, %eax
	
	
	syscall


