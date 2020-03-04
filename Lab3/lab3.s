
# Useful constants
        .equ    STDIN,0
        .equ    STDOUT,1
        .equ    READ,0
        .equ    WRITE,1
        .equ    EXIT,60
# Stack frame
        .equ localSize,-16
# Read only data
        .section .rodata       # the read-only data section
Name:
        .string "What is your name?: "
        .equ    NameSz,.-Name-1
       
Greeting:
.string "Hello "
.equ GreetingSz,.-Greeting-1

Error:
.string "Error, Please try a different name\n"
.equ ErrorSz,.-Error-1
Error1:
.string "Error, Please input a valid number\n"
.equ Error1Sz,.-Error1-1
Error2:
.string "Error, Please input another valid number\n"
.equ Error2Sz,.-Error2-1

NumInput:
.string "Enter in a number: "
.equ NumInputSz,.-NumInput-1

NumInput2:
.string "Enter in another number: "
.equ NumInput2Sz,.-NumInput2-1

Add:
.string "The sum of the two numbers is: \n"
.equ AddSz,.-Add-1

Sub:
.string "The difference of the two numbers is: \n"
.equ SubSz,.-Sub-1

SubIF:
.string "The difference of the two numbers is: - \n"
.equ SubIFSz,.-SubIF-1

Mult:
.string "The product of the two numbers is: \n"
.equ MultSz,.-Mult-1
       
Division:
.string "The quotient of the two numbers is: \n"
.equ DivisionSz,.-Division-1

Remainder:
.string "The remainder is:  \n"
.equ RemainderSz,.-Remainder-1

# Code
        .text                   # switch to text section
        .globl  _start
 
_start:
        pushq   %rbp           # save caller’s frame pointer
        movq    %rsp, %rbp     # establish our frame pointer
        addq    $localSize, %rsp   # for local variable

greet:
movl $NameSz, %edx #asks the user for their name
movl $Name, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

movl $16, %edx #takes the name input
leaq -16(%rbp), %rsi
movl $STDIN, %edi
movl $READ, %eax
syscall

subl $1, %eax #sub 1 to get rid on newline

errorCheck:
leaq -16(%rbp), %r9 #checks the stack for first
andb $0xdf, (%r9) #1st letter will always be capital
cmpb $0x41 ,(%r9) #compared against capital ascii
jb error
cmpb $0x5a, (%r9)
ja error

movq $1, %r10 #counter for this loop (1 is moved to skip 1st character)

Loop:
addq $1, %r9 #increment the memory address
orb $0x20, (%r9) #all other characters are lower case
cmpb $0x61 ,(%r9) #ascii range for lower case
jb error
cmpb $0x7a, (%r9)
ja error

addq $1, %r10 #increment counter
cmpl %eax, %r10d #comparison of number of letters and counter
jl Loop  

movl $GreetingSz, %edx #Greets the user
movl $Greeting, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

movl $16, %edx
leaq -16(%rbp), %rsi #displays name
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

movq $0, %r9 #zeros out r9 to take num input
jmp numInput

error:
movl $ErrorSz, %edx #error message asking user to resubmit
movl $Error, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

jmp greet

error1:
movl $Error1Sz, %edx #Error please enter a valid num
movl $Error1, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall


numInput:
movl $NumInputSz, %edx #asks the user to input a number
movl $NumInput, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

movl $16, %edx #takes number input
leaq -16(%rbp), %rsi
movl $STDIN, %edi
movl $READ, %eax
syscall

movq $0, %r10

movq $0, %rdi
leaq -16(%rbp), %rdi #Grabbing first number and storing it (memory address)
subl $1, %eax #get rid of newline
call numCheck

movq %rax, %rdi #first param (memory address)
movq %r10, %rsi #second param (num of digits)
movq $0, %rdx #third param (counter)
movq $1, %r12 #r12 is power of (x)
call asciToInt
movq $0, %r14 #0 out r14 register which holds int version on num entered
movq %rax, %r8 #store int version into r8
jmp numInput2

numCheck:
cmpb $0x30 ,(%rdi) #checks ascii range for numbers
jb error1
cmpb $0x39, (%rdi)
ja error1

addq $1, %rdi #increment memory address
addq $1, %r10 #increment counter
cmpl %eax, %r10d #compare digits to counter
jl numCheck  
movq %rdi, %rax #move memory address to rax to return it
ret

numCheck2:
cmpb $0x30 ,(%rdi) #checks ascii range again
jb error2
cmpb $0x39, (%rdi)
ja error2

addq $1, %rdi
addq $1, %r10
cmpl %eax, %r10d
jl numCheck2  
movq %rdi, %rax
ret

error2:
movl $Error1Sz, %edx #Error please enter a valid num
movl $Error1, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall


numInput2:
movl $NumInput2Sz, %edx #asks the user to input a number
movl $NumInput2, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

movl $16, %edx #takes input
leaq -16(%rbp), %rsi
movl $STDIN, %edi
movl $READ, %eax
syscall

movq $0, %r10
leaq -16(%rbp) ,%rdi
subl $1, %eax
call numCheck2

movq %rax, %rdi #first param (memory address)
movq %r10, %rsi #second param (num of digits)
movq $0, %rdx #third param (counter)
movq $1, %r12 #r12 is power of (x)
call asciToInt
movq %rax, %r9
jmp addition

asciToInt:
dec %rdi #while looping subtract the memory address
inc %rdx #increment the counter

movq (%rdi), %r15 #grab digit value
subq $0x30, %r15 #subtract 30 for ascii conversion
movb %r15b, %r13b #storing ascii conversion into r13
movq %r13, (%rdi) #making ascii conversion value into first param

call powerOf
ret

powerOf: #nested function
movq (%rdi), %r15 #r15 grabs value starting from last digit
imulq %r12, %r15 #this is the power of (10^x)
imulq $10, %r12 #increses the power of 10 to r12 everytime it loops
addq %r15, %r14 #value gets accumilated into r14

cmpl %esi, %edx #comaparing number of digits to counter
jl asciToInt

movq %r14, %rax #return value
ret

addition:
movq %r8, %r13 #made r8 and r9 global variables to use in every
movq %r9, %r12 #arithmetic operation

addq %r13, %r12 #adds values

movq %r12, %rdi
pushq %r12
#call intToAscii

movl $AddSz, %edx #prints out the sum is
movl $Add, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall



subtraction:
movq %r8, %r13
movq %r9, %r12


cmpl %r12d, %r13d #if first value is larger than first
jl subIfNegative

movl $SubSz, %edx
movl $Sub, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

subq %r13, %r12 #subtraction normal if second num is smaller
jmp multiply

subIfNegative:
subq %r13, %r12

movl $SubIFSz, %edx #if second num is larger then we get negative output
movl $SubIF, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

multiply:
movq %r8, %r13
movq %r9, %r12
imulq %r13, %r12

movl $MultSz, %edx
movl $Mult, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

divide:
movq %r8, %r13
movq %r9, %r12

movq $0, %rdx
movq %r12, %rax

divq %r13

movl $DivisionSz, %edx
movl $Division, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall

movq %rax, %r12 #quotient
movq %rdx, %r13 #remainder

movl $RemainderSz, %edx
movl $Remainder, %esi
movl $STDOUT, %edi
movl $WRITE, %eax
syscall


test:
        movq    %rbp, %rsp     # delete local variables
        popq    %rbp           # restore caller’s frame pointer
        movl    $EXIT, %eax     # exit from this process
        syscall

