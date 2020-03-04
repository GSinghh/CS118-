# echoChar3.s
# Prompts user to enter a character, then echoes the response
# Does not use C libraries
# Bob Plantz -- 11 June 2009
 
# Useful constants
        .equ    STDIN,0
        .equ    STDOUT,1
        .equ    READ,0
        .equ    WRITE,1
        .equ    EXIT,60
# Stack frame
        .equ    aNumber,-16
        .equ localSize,-16
        .equ    bNumber,-32
# Read only data
        .section .rodata       # the read-only data section
prompt:
        .string "Enter two 2 digit numbers (10-99): "
        .equ    promptSz,.-prompt-1
       
prompt2:
        .string "Enter a number to subtract smaller than first: "
        .equ    prompt2Sz,.-prompt2-1
       
msg:
        .string "The Final result is: "
        .equ    msgSz,.-msg-1
# Code
        .text                  # switch to text section
        .globl  _start
 
_start:
        pushq   %rbp           # save caller’s frame pointer
        movq    %rsp, %rbp     # establish our frame pointer
        addq    $localSize, %rsp  # for local variable
 
        movl    $promptSz, %edx # prompt size
        movl    $prompt, %esi  # address of prompt text string
        movl    $STDOUT, %edi  # standard out
        movl    $WRITE, %eax
        syscall                # request kernel service
 
        movl    $3, %edx       # 1 character, plus newline
        leaq    aNumber(%rbp), %rsi # place to store character
        movl    $STDIN, %edi   # standard in
        movl    $READ, %eax    
        syscall                # request kernel service
       
        movl    $prompt2Sz, %edx # prompt size
        movl    $prompt2, %esi  # address of prompt text string
        movl    $STDOUT, %edi  # standard out
        movl    $WRITE, %eax
        syscall                # request kernel service  
       
        leaq    bNumber(%rbp), %rsi # place to store character
        movl    $STDIN, %edi   # standard in
        movl    $READ, %eax    
        syscall                # request kernel service

	movb aNumber(%rbp), %al #38
	movb (aNumber+1)(%rbp), %bh #37

	subb $0x30, %al
	subb $0x30, %bh

	movb $10, %cl
	mulb %cl

	addb %al, %bh

	movb bNumber(%rbp), %al
	movb (bNumber+1)(%rbp), %bl

	subb $0x30, %al
	subb $0x30, %bl

	mulb %cl	

	addb %bl, %al
	subb %al, %bh

	movb %bh, %al
	movb $0, %ah

	divb %cl

	addb $0x30, %al
	addb $0x30, %ah

	movq %rax, %rcx
	movq $0, %rax
	movw %cx, %axclear
	pushq %rax

        movl    $msgSz, %edx   # message size
        movl    $msg, %esi     # address of message text string          
        movl    $STDOUT, %edi  # standard out  
        movl    $WRITE, %eax
        syscall                # request kernel service
 
	movl $3, %edx # 1 character, plus newline
	leaq    (%rsp), %rsi # place to store character
        movl    $STDOUT, %edi  # standard out
        movl    $WRITE, %eax
        syscall                # request kernel service  
       
        movq    %rbp, %rsp     # delete local variables
        popq    %rbp           # restore caller’s frame pointer
        movl    $EXIT, %eax    # exit from this process
        syscall
