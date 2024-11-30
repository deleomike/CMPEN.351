.data 

Int1: .word 1
Int2: .word 1
Op: .word 1
Result: .word 1
remains: .word 1

prompt1: .asciiz "\nEnter First Integer: "
prompt2: .asciiz "Enter Operator: "
prompt3: .asciiz "\nEnter Second Integer: "


.text

main:

la $a0, prompt1		#prompt
la $a1, Int1		#where to save the first integer
jal GetInput

la $a0, prompt2		#prompt
jal GetOperator		

la $a0, prompt3		#prompt
la $a1, Int2		#where to save the second integer
jal GetInput

la $a0, Int1		#loads first int
la $a1, Int2		#loads second int
la $a2, Result		#loads address of result

la $ra DisplayNumb
beq $v1, 42, MultNumb
beq $v1, 43, AddNumb
beq $v1, 45, SubNumb
beq $v1, 47, DivNumb



j end_
#pre: $a0 is string to print, $a1 is place to store input
#Post: stores input at $a1 address
GetInput:
	li $v0, 4	#Prints string
	syscall
	
	li $v0, 5	#reads input
	syscall
	
	sw $v0, 0($a1)	#stored inputm
	
	jr $ra
	
#pre: $a0 is string to print
#post: returns operator in $v0, as an ascii
GetOperator:
	li $v0, 4	#prints string
	syscall
	
	li $v0, 12	#reads character
	syscall
	
	move $v1, $v0	#returns ascii character
	
	jr $ra

#pre: a0 points to first int, a1 points to second int, a2 points to result
#post: add the inputs, store to result
AddNumb:
	lw $t1, 0($a0)
	lw $t2, 0($a1)
	add $t0, $t1, $t2		#adds the two integers
	sw $t0, 0($a2)		#stores the result from $t0
	
	la $a0, Int1	#loads first int
	li $a1, 43	#loads operator ASCII value
	la $a2, Int2	#loads second int
	la $a3, Result	#loads result
	
	jr $ra	#return to displaynumb as it is with the equation

#pre: a0 points to first int, a1 points to second int, a2 points to result
#post: subtracts a0 - a1 = a2, store to result
SubNumb:
	lw $t1, 0($a0)
	lw $t2, 0($a1)
	sub $t0, $t1, $t2		#subtracts first from second
	sw $t0, 0($a2)			#stores result
	
	#print
	la $a0, Int1	#loads first int
	li $a1, 45	#loads operator ASCII value
	la $a2, Int2	#loads second int
	la $a3, Result	#loads result
	
	jr $ra
	

#pre: a0 points to first int, a1 points ti second int, a2 points to result
#post: multiplies inputs, store to result
MultNumb:
	lw $s0, 0($a0)
	lw $s1, 0($a1)
	
	
	modulus:
	
	addi $t0, $0, 2	#first shift amount to test
	#find less than, but next is not
	add $t6, $0, $0 #counter
	add $t7, $0, $0 #continue or no
	
	#first attempt
	sltu $t7, $s1, $t0	#test if the shift is greater or not
	addi $t6, $t6, 1
	bne $t7, $0, end
	loop:
		sll $t0, $t0, 1	#second attempt
		#divide by first
		sltu $t7, $s1, $t0	#test if the shift is greater or not
		addi $t6, $t6, 1
		beq $t7, $0, loop
	end:
	srl $t0, $t0, 1
	sub $v0, $t6, 1
	sub $t4, $s1, $t0
	
	#try 2, 4, 8, 16... until one is less than, but the next is not
	#t4 is remainder, $t5 is a counter, t1 is a remainder * first input
	sllv $t0, $s0, $v0	#Multiplies by greates shift amount possible

	#if remainder loop back modulus
	add $t3, $t0, $t3 #partial total
	move $s1, $t4
	bne $t4,$0, modulus

	sw $t3, 0($a2)	#Stores result to address
	
	#print
	la $a0, Int1	#loads first int
	li $a1, 42	#loads operator ASCII value
	la $a2, Int2	#loads second int
	la $a3, Result	#loads result
	
	jr $ra
	
	

DivNumb:
	lw $s0, 0($a0)
	lw $s1, 0($a1)
	move $a0, $s0	#load inputs
	move $a1, $s1
	
	add $v0, $0, $0
	#initially it goes in 0 times
	add $t1, $a1, $0
	#copy $a1 to $t1
	jal chko
	
oloop:  add $t1, $a1, $0
	#divisor multiple starts at 1x
	add $t2, $0, 1
	#initialize temp quotient to 1
	jal chki
	
inloop:  sll $t2, $t2, 1
	#multiply temp quotient by 2
	sll $t1, $t1, 1
	#multiply divisor by 2
	chki:
	sltu $t0, $a0, $t1
	#if remaining dividend is less than div multiple
	beq $t0, $zero, inloop   #fall through to add temp quotient
	addu $v0, $v0, $t2
	#add temp quotient to running
	srl $t1, $t1, 1
	#undo last divisor multiply
	sub $a0, $a0, $t1
	#subtract biggest multiple from dividend
	chko:
	sltu $t0, $a0, $a1
	#set $t0 if $a0 < $a1
	beq $t0, $0, oloop
	#repeat until div is calculated
	
	srl $v0, $v0, 1
	
	sw $v0, 0($a2)
	
	sw $a0, remains
	
	la $a0, Int1	#loads first int
	li $a1, 47	#loads operator ASCII value
	la $a2, Int2	#loads second int
	la $a3, Result	#loads result
	
	la $ra, DisplayNumb
	
	jr $ra
	

#prints out remainder for division
remainder:
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	li $a0, 82	#prints R in ASCII
	li $v0, 11
	syscall
	
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	lw $a0, 0($a1)	#loads remainder
	li $v0, 1
	syscall		#prints remainder
	
	j main
	
	

#pre: $a0 is pointed to first int, $a1 is loaded with operator, $a2 is pointed to second int, $a3 is pointed to result
#post: prints equation
DisplayNumb:
	lw $t0, 0($a0)		#loads first int
	move $a0, $t0
	li $v0, 1		#prints first int
	syscall
	
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	#operator
	move $a0, $a1
	li $v0, 11
	syscall
	
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	
	lw $t0, 0($a2)	#load second int
	move $a0, $t0	#copy to parameter
	li $v0, 1	
	syscall
	
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	
	li $a0, 61	#equal sign
	li $v0, 11
	syscall
	
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	lw $t0, 0($a3)	#points to result
	move $a0, $t0
	li $v0, 1
	syscall		#prints result
	
	la $a1, remains		#points to remainder
	beq $v1, 47, remainder	#prints remainder if division
		
	j main


end_:
