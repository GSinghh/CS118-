#useful Constants

	.equ	STDIN,0
	.equ	STDOUT,1
	.equ	READ,0
	.equ	WRITE,1
	.equ	EXIT,60

#Stack Frame
	.equ    aNumber,-16
	.equ    bNumber,-32

#Read only data

	.section .rodata
userGreeting:
		.string "Enter in a name: "
		.equ	userGreetingSz,.-userGreeting-1

errorCheck: 
		.string "Your Name is too long \n"
		.equ errorCheckSz,.-errorCheck-1

endProgram:
		.string "Program Ending, Goodbye \n"
		.equ endProgramSz,.-endProgram-1

userGreeting2: 
		.string "Your Name is: "
		.equ userGreeting2Sz,.-userGreeting2-1

prompt1:
		.string "Enter in a two digit number: "
		.equ prompt1Sz,.-prompt1-1

prompt2: 
		.string "Enter in another two digit number: "
		.equ prompt2Sz,.-prompt2-1

additionFinal:
		.string "The Sum is: "
		.equ additionFinalSz,.-additionFinal-1

finalAnswer:
		.string "The difference is: "
		.equ finalAnswerSz,.-finalAnswer-1

# Code Starts Here

	.text
	.globl _start


_start:
	#prologue starts here
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq $0, %r15 #intialize r15 to 0, used as counter
	jmp Greeting #jump straight to user greeting
		
errorChecking:
	
	#Printing out the prompt if name exceeds character limit
	movl $errorCheckSz, %edx
	movl $errorCheck, %esi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall
	
	#We use r15 as a counter and increment once everytime user enters in a invalid name
	addq $1, %r15
	cmpq $2, %r15
	ja endingProgram #Jump to ending program once user has 3 tries
	
Greeting:	#Greets user and asks for a name

		
	
	movl $userGreetingSz, %edx
	movl $userGreeting, %esi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall

	
	movl $16, %edx
	leaq -16(%rbp), %rsi
	movl $STDIN, %edi
	movl $READ, %eax
	syscall
	
	#Compares the value in eax, which is the amount of characters entered in with the value 10
	cmpl $10, %eax
	ja errorChecking # If Character limit exceeds, jump above to errorChecking label. Else, go to PASS
	jmp PASS


PASS:	#Prints out Users Name and
	#Greets and Takes input for first and second number
	
	movl $0, %r8d
	movl %eax, %r8d
	
	movl $userGreeting2Sz, %edx
	movl $userGreeting2, %esi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall

	
	movl %r8d, %edx
	leaq -16(%rbp), %rsi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall
	
	movl $prompt1Sz, %edx
	movl $prompt1, %esi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall

        leaq    -16(%rbp), %rsi # place to store character
        movl    $STDIN, %edi   # standard in
        movl    $READ, %eax    
        syscall 

	movl    $prompt2Sz, %edx # prompt size
        movl    $prompt2, %esi  # address of prompt text string
        movl    $STDOUT, %edi  # standard out
        movl    $WRITE, %eax
        syscall                # request kernel service  
       
        leaq    bNumber(%rbp), %rsi # place to store character
        movl    $STDIN, %edi   # standard in
        movl    $READ, %eax    
        syscall                # request kernel service

	movb aNumber(%rbp), %al # Stores 1st half of number
	movb (aNumber+1)(%rbp), %bh # Stores 2nd half of inputted number

 	subb $0x30, %al #Subtracting 0x30 from both registers
	subb $0x30, %bh

	movb $10, %cl #Multiplying 10 with tens digit to get it to correct value
	mulb %cl

	addb %al, %bh #Adding values from both registers to get first number entered in
	
	movb bNumber(%rbp), %al #Same process as first number
	movb (bNumber+1)(%rbp), %bl

	subb $0x30, %al
	subb $0x30, %bl

	mulb %cl	

	addb %bl, %al
	#Compares Second number with first to see if its larger, if it is larger jump to subtractionIfNegative label, else go to Subtraction
	cmpb %al, %bh
	jl subtractionIfNegative

subtraction: #Subtracts first value with second and pushes the difference onto the stack. Jumps to endingProgram after finishing
	subb %al, %bh

	movb %bh, %al
	movb $0, %ah

	divb %cl

	addb $0x30, %al
	addb $0x30, %ah

	movq %rax, %rcx
	movq $0, %rax
	movw %cx, %ax
	pushq %rax
	
	movl $finalAnswerSz, %edx
	movl $finalAnswer, %esi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall
	
	leaq   (%rsp), %rsi
	movb $0xa, 2(%rsi)
	movl $3, %edx # 1 character, plus newline
	leaq    (%rsp), %rsi # place to store character
        movl    $STDOUT, %edi  # standard out
        movl    $WRITE, %eax
        syscall 
	jmp endingProgram


subtractionIfNegative: #Does the same thing as subtraction but prints out if first value is smaller than the second
	
	subb %bh, %al

	movb %al, %bh
	movb $0, %ah

	divb %cl

	addb $0x30, %al
	addb $0x30, %ah

	movq %rax, %rcx
	movq $0, %rax
	movw %cx, %ax
	pushq %rax
	
	movl $finalAnswerSz, %edx
	movl $finalAnswer, %esi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall
	
	leaq   (%rsp), %rsi
	movb $0xa, 2(%rsi)
	movl $3, %edx # 1 character, plus newline
	leaq    (%rsp), %rsi # place to store character
        movl    $STDOUT, %edi  # standard out
        movl    $WRITE, %eax
        syscall 	


#addition: Didn't have enough time to finish the addition function
	
	#movl $additionFinalSz, %edx
	#movl $additionFinal, %esi
	#movl $STDOUT, %edi
	#movl $WRITE, %eax
	#syscall	

	#movl $3, %edx # 1 character, plus newline
	#leaq    -8(%rbp), %rsi # place to store character
        #movl    $STDOUT, %edi  # standard out
        #movl    $WRITE, %eax
        #syscall 

	#movq %rbp, %rsp     # delete local variables
        #popq %rbp           # restore caller’s frame pointer
        #movl $EXIT, %eax    # exit from this process
	#syscall

endingProgram: #Ends Program Pops off stack
	movl $endProgramSz, %edx
	movl $endProgram, %esi
	movl $STDOUT, %edi
	movl $WRITE, %eax
	syscall
	
	movq %rbp, %rsp     # delete local variables
        popq %rbp           # restore caller’s frame pointer
        movl $EXIT, %eax    # exit from this process
	syscall
	
	

