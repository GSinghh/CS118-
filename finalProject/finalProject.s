#useful constants
.equ input, -16
.equ repeat, -8
.equ STDIN, 0
.equ STDOUT, 1
.equ READ, 0
.equ WRITE, 1
.equ input, -16
    .section .rodata
askNum:
    .string "Please enter a number: "
    .equ askNumSz, .-askNum-1
askOperation:
    .string "Choose one operation to be performed (+ - * /): "
     .equ askOperationSz, .-askOperation-1
addResult:
    .string "The addition of the first two numbers is: "
    .equ addResultSz, .-addResult-1
subResult:
    .string "The subtraction of the first two numbers is: "
    .equ subResultSz, .-subResult-1
multResult:
    .string "The multiplication of the first two numbers is: "
     .equ multResultSz, .-multResult-1
divResult:
    .string "The division result of the first two numbers is: "
    .equ divResultSz, .-divResult-1
askRepeat:
    .string "Would you like to make another calculation?\nPress q to quit or any key to continue: "
    .equ askRepeatSz, .-askRepeat-1
period:
    .string "."
    .equ periodSz, .-period-1
numberOfNums:
    .string "How many numbers would you like to enter (3-5): "
    .equ numberOfNumsSz, .-numberOfNums
PEError:
    .string "Precision Exception !\n"
    .equ PEErrorSz, .-PEError-1
EndLine:
        .string "!\n"
        .equ EndLineSz, .-EndLine-1
.data
     multiplier: .float 10
     multiplier2: .float 100000000
     multiplier3: .float 0.1
     state: .long    0
.text
.globl _start

_start:

    pushq     %rbp
    movq     %rsp, %rbp
    subq     $64, %rsp
askAgain:
    movq    $0,  %r13

    movl $numberOfNumsSz, %edx
    movl $numberOfNums, %esi
    movl $1, %edi
    movl $1, %eax
    syscall

    movl $16, %edx
    leaq -16(%rbp), %rsi
    movl $0, %edi
    movl $0, %eax
    syscall
    movq $0, %r15
    movb (%rsi), %r15b
    subb $0x30,%r15b
    subb $1, %r15b 

    jmp userInput

arrayStoring:
    movss    %xmm0, -48(%rbp, %r13, 4)
    inc         %r13
    cmpq     %r15, %r13
    addss %xmm0, %xmm9
    jle         userInput
average:
    addq $1, %r13
    cvtsi2ss %r13d, %xmm8
    divss %xmm8, %xmm9

    jmp askForOperation

userInput:
    movl     $askNumSz, %edx #Printing out first prompt
    movl     $askNum, %esi
    movl     $1, %edi
    movl     $1, %eax
    syscall

    movl     $16, %edx
    leaq     -16(%rbp), %rsi  #Getting input from user
    movl     $0, %edi
    movl     $0, %eax
    syscall

    call        AsciiToFloat
    jmp         arrayStoring

askForOperation:
    movl     $askOperationSz, %edx #Printing out askOperation prompt
    movl     $askOperation, %esi
    movl     $1, %edi
    movl     $1, %eax
    syscall

    movl     $2, %edx
    leaq     -8(%rbp), %rsi  #Getting operation
    movl     $0, %edi
    movl     $0, %eax
    syscall

    movb     (%rsi), %bl
    cmpb    $'+', %bl
    je            Add
    cmpb    $'-', %bl
    je            Sub
    cmpb    $'*', %bl
    je            Mult
    cmpb    $'/', %bl
    je            Div
Add:
    movq     $1, %rdx
    movq     $0, %rsi
    leaq     -48(%rbp), %rdi
    call           Addition
    jmp        DisplayOperationResult
Sub:
    movq     $1, %rdx
    movq     $0, %rsi
    leaq     -48(%rbp), %rdi
    call         Subtraction
    jmp       DisplayOperationResult
Mult:
    movq     $1, %rdx
    movq     $0, %rsi
    leaq     -48(%rbp), %rdi
    call         Multiplication
    jmp        DisplayOperationResult
Div:
    movq     $1, %rdx
    movq     $0, %rsi
    leaq     -48(%rbp), %rdi
    call Division

DisplayOperationResult:
    pushq    %rax
    movss    %xmm0, %xmm1
    call    DisplayResult
    popq    %rdi
    call        PrecisionException

    movl     $askRepeatSz, %edx
    movl     $askRepeat, %esi
    movl     $STDOUT, %edi
    movl     $WRITE, %eax
    syscall

    movl     $8, %edx
    leaq     repeat(%rbp), %rsi
    movl     $STDIN, %edi
    movl     $READ, %eax
    syscall

    leaq repeat(%rbp), %rsi
    movb (%rsi), %al
    cmpb $'q', %al
    je exit
    jmp askAgain

exit:
    movq     %rbp, %rsp
    popq     %rbp
    movl     $60, %eax
    syscall
AsciiToFloat:
    pushq     %rbp
    movq     %rsp, %rbp
    movss     multiplier3, %xmm3
    movl     $0, %eax

    checkDot: 
    movb     (%rsi), %bl
    inc         %rsi
    cmpb     $0x2e, %bl
    jne         storeDot
    jmp         dotFound

storeDot:
    movq     $10, %rcx
    subb     $0x30, %bl
    addb     %bl, %al
    mulb     %cl
    jmp         checkDot

dotFound:
    divb     %cl
    cvtsi2ss %eax, %xmm0 

checkA:
    movb     (%rsi), %bl
    inc         %rsi
    cmpb     $0xa, %bl
    jne         hexToFloat
    jmp         storeFloat

hexToFloat:
        subb     $0x30, %bl
        cvtsi2ss     %ebx, %xmm1
        mulss     %xmm3, %xmm1
        addss   %xmm1, %xmm0
        mulss     multiplier3, %xmm3
        jmp         checkA

storeFloat:
        movq     %rbp, %rsp
        popq     %rbp
        ret
Addition:
        pushq %rbp
        movq %rsp, %rbp

        movss    (%rdi, %rsi, 4), %xmm0
        movss    (%rdi, %rdx, 4), %xmm1

        movl     $addResultSz, %edx
        movl     $addResult, %esi
        movl     $STDOUT, %edi
        movl     $WRITE, %eax
        syscall

        addss %xmm1, %xmm0
        stmxcsr   state
        movl    $0x0020, %eax
        andl        state, %eax

        movq %rbp, %rsp
        popq %rbp
        ret
Subtraction:
    pushq %rbp
    movq %rsp, %rbp
    movss    (%rdi, %rsi, 4), %xmm0
    movss    (%rdi, %rdx, 4), %xmm1

    movl     $subResultSz, %edx 
    movl     $subResult, %esi
    movl     $STDOUT, %edi
    movl     $WRITE, %eax
    syscall

    subss %xmm1, %xmm0
    stmxcsr   state
    movl    $0x0020, %eax
    andl        state, %eax

    movq %rbp, %rsp
    popq %rbp
    ret
Multiplication:
    pushq     %rbp
    movq     %rsp, %rbp

    movss    (%rdi, %rsi, 4), %xmm0
    movss    (%rdi, %rdx, 4), %xmm1

    movl     $multResultSz, %edx #Printing out multiplication prompt
    movl     $multResult, %esi
    movl     $1, %edi
    movl     $1, %eax
    syscall

    mulss    %xmm1, %xmm0
    stmxcsr   state
    movl    $0x0020, %eax
    andl        state, %eax

    movq     %rbp, %rsp
    popq     %rbp
    ret 

Division:
    pushq %rbp
    movq %rsp, %rbp

    movss    (%rdi, %rsi, 4), %xmm0
    movss    (%rdi, %rdx, 4), %xmm1

    movl     $divResultSz, %edx 
    movl     $divResult, %esi
    movl     $STDOUT, %edi
    movl     $WRITE, %eax
    syscall

    divss     %xmm1, %xmm0
    stmxcsr   state
    movl    $0x0020, %eax
    andl        state, %eax

    movq %rbp, %rsp
    popq %rbp
    ret
DisplayResult:
    pushq  %rbp
    movq   %rsp, %rbp

    movss    %xmm1, %xmm2
    mulss    multiplier, %xmm1
    call         floatToInt
    pushq     %rax
    movq    %rax, %rdi
    call        DigitsNum
    popq    %rdi
    pushq     %rax
    pushq    %rdi
    movq    %rax, %rsi
    call        IntToAscii

    movq    %rax, %rdi
    call         DisplayNum

    movl    $periodSz, %edx
    mov        $period, %esi
    movl    $STDOUT, %edi
    movl    $WRITE, %eax
    syscall

    popq    %rax
    cvtsi2ss    %rax, %xmm1
    subss    %xmm1, %xmm2

    movq    $10, %rdi
    popq    %rbx
    subq    %rbx, %rdi
    pushq    %rdi
    call TenMultiplier
    cvtsi2ss %rax, %xmm3
    mulss    %xmm3, %xmm2
    movss    %xmm2, %xmm1
    call         floatToInt
    movq    %rax, %rdi
    popq    %rsi
    dec        %rsi
    call        IntToAscii

    movq    %rax, %rdi
    call         DisplayNum


    movl    $EndLineSz, %edx
    mov        $EndLine, %esi
    movl    $STDOUT, %edi
    movl    $WRITE, %eax
    syscall

    movq     %rbp, %rsp
    popq     %rbp
    ret
TenMultiplier:
    pushq    %rbp
    movq    %rsp, %rbp

    movq    $10, %rcx
    movq    $1, %rax
multplyByTen:
    mulq    %rcx
    dec        %rdi
    cmpq    $0, %rdi
    jne    multplyByTen

    movq     %rbp, %rsp
    popq     %rbp
    ret 
DisplayNum:
    pushq    %rbp
    movq    %rsp, %rbp

    pushq    %rdi
    movl    $8, %edx
    leaq    (%rsp), %rsi
    movl    $STDOUT, %edi
    movl    $WRITE, %eax
    syscall
    popq     %rdi

    movq     %rbp, %rsp
    popq     %rbp
    ret
floatToInt:
    pushq    %rbp
    movq    %rsp, %rbp

    cvtss2si     %xmm1, %rax
    movq    $0, %rdx
    movq    $10, %rcx
    divq        %rcx

    movq     %rbp, %rsp
    popq     %rbp
    ret 
IntToAscii:
        pushq    %rbp
        movq    %rsp, %rbp
        movq      %rdi, %rax
        movq    $10, %rcx
        movq    $0, %rdx
        movq    $0, %r10
        movq    $0, %rbx

ConvertingToAscii:
        divq        %rcx
        cmpq    $1, %rbx
        je        convertNum
        cmpq    $0, %rdx
        jne        convertNum
        dec        %esi
        cmp      $0, %esi
        jne        ConvertingToAscii
        movq    $0x30, %rax
        jmp        existIntToAscii

convertNum:
        movq     $1, %rbx
        addq    $0x30, %rdx
        addq    %rdx, %r10
        shlq        $8, %r10
        movq    $0, %rdx
        subl        $1, %esi
        cmp      $0, %esi
        jne        ConvertingToAscii 

        shrq        $8, %r10
        movq    %r10, %rax
existIntToAscii:
        movq    %rbp, %rsp
        popq     %rbp
        ret

DigitsNum:
        pushq    %rbp
        movq    %rsp, %rbp
        movl    $0, %ebx
        movl     $10, %ecx
        movl    %edi, %eax
DigitsLoop:
        movl    $0, %edx
        divl         %ecx
        addl        $1, %ebx
        cmpl    $0, %eax
        jne        DigitsLoop
        movl     %ebx, %eax

        movq    %rbp, %rsp
        popq     %rbp
        ret
PrecisionException:
        pushq    %rbp
        movq    %rsp, %rbp

        cmpq    $0, %rdi
        je            PEExit

        movl    $PEErrorSz, %edx
        mov        $PEError, %esi
        movl    $STDOUT, %edi
        movl    $WRITE, %eax
        syscall

PEExit:
        movq    %rbp, %rsp
        popq     %rbp
        ret
