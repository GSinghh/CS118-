# Irman Mashiana, Gurpreet Singh
#10/16/19

.section .rodata
msg:
.string "Hello World!\n"
.equ msgSz,.-msg-1

prompt:
.string "What is your name?: "
.equ promptSz,.-prompt-1

prompt2:
.string "Your name is: "
.equ prompt2Sz, .-prompt2-1

prompt3:
.string "Error, please try again:  "
.equ prompt3Sz, .-prompt3-1


.text
.globl _start

_start:
pushq %rbp
movq %rsp, %rbp
addq $-16, %rsp

#movl $msgSz, %edx
#movl $msg, %esi
#movl $1, %edi
#movl $1, %eax
#syscall

movl $promptSz, %edx
movl $prompt, %esi
movl $1, %edi
movl $1, %eax
syscall

movl $16, %edx
leaq -16(%rbp), %rsi
movl $0, %edi
movl $0, %eax
syscall

#comparing 11 to the number of characters
cmpl $11, %eax
ja jump1



PASS:
movl $0, %r8d
movl %eax, %r8d
movl $prompt2Sz, %edx
movl $prompt2, %esi
movl $1, %edi
movl $1, %eax
syscall

#print the name
subq $1, %r8
movl %r8d, %edx
leaq -16(%rbp), %rsi
movl $1, %edi
movl $1, %eax
syscall
 
movq %rbp, %rsp
popq %rbp
movl $60, %eax
syscall



jump1:
movl $prompt3Sz, %edx
movl $prompt3, %esi
movl $1, %edi
movl $1, %eax
syscall

movl $16, %edx
leaq -16(%rbp), %rsi
movl $0, %edi
movl $0, %eax
syscall

jmp PASS

#If the name is very short, it'll print out like normal
#and null the rest.

#if the name is very long, it will only store the
#amount of characters that we allocated, the rest gets
#run as a command in terminal. But if we increase
#the stack size it will print it all out

#if the name is longer than the allocated callstack
#the output will only be as long as the amount
#of memory we allocated. Anything outside of the
#call stack doesn't get stored. 
