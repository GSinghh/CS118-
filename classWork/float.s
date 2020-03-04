.data
	num1: .long 2
	num2: .long 5
	numf1: .float

.globl _start

_start
	pushq %rbp
	movq %rsp, %rbp

	cvtsi2ss num1, %xmm0
	cvtsi2ss num2, %xmm1
	addss %xmm1. %xmm0

	mulss numf1, %xmm0

	movq %rbp, %rsp
	popq %rbp
	ret