# Useful constants
        .equ    STDIN,0
        .equ    STDOUT,1
        .equ    READ,0
        .equ    WRITE,1
        .equ    EXIT,60

# Read Only Data
	.section .rodata

prompt:
	.string "Enter in a sentence: "
	.equ promptSz,.-prompt-1
