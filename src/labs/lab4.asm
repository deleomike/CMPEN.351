.data

next: .asciiz "\n"
PANDA: .asciiz "Result: "
incorrect: .asciiz "Incorrect Operator\n"
prompt1: .asciiz "Enter the first integer: "
prompt2: .asciiz "Enter the operator: "
prompt3: .asciiz "\nEnter the second integer: "
equal: .ascii "="
space: .ascii " "

temp1: .word 1
temp2: .word 1
temp3: .word 1
result: .word 1

.text

main:
#First integer prompt
la $a0, prompt1	
la $a1, temp1
jal GetInput

#operator
la $a0, prompt2
jal GetOperator

move $t1, $v1
sw $t1, temp2

la $a0, prompt3
la $a1, temp3
jal GetInput

jal load


beq $t1, 43, AddNumb	#add the numbers
beq $t1, 45, SubNumb	#subtract the numbers
beq $t1, 47, DivNumb	#divide the numbers
beq $t1, 42, MultNumb	#multiply the numbers

la $a0, incorrect
li $v0, 4
syscall
jal main

GetInput:
	li $v0, 4
	syscall

	#takes the first integer
	li $v0, 5
	syscall
	
	sw $v0, 0($a1)
	
	jr $ra
	

GetOperator:
#Asks for operator
la $a0, prompt2
li $v0, 4
syscall

#takes operator (whatever value will be referred to on the ASCII table
li $v0, 12
syscall

move $v1, $v0

jr $ra


#pre: first int t0, second int t2
#post adds the two numbers
AddNumb:
	add $t3, $t0, $t2 #adds the numbers
	jal print_eq

#pre: first int t0, second int t2
#post: subtracts t0 - t2
SubNumb:
	sub $t3, $t0, $t2	#subtracts the numbers
	jal print_eq

#pre: first int t0, second int t2
#post: divides t0 by t2
DivNumb:

	jal save
	move $a0, $t0	#load inputs
	move $a1, $t2
	
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
	
	move $t3, $v0
	
	jal load
	
	jal save
	jal print_eq
	
	

#pre: first int t0, second int t2
#post: multiplies the numbers		
MultNumb:
	jal save
	move $a0, $t0
	move $a1, $t2
	modulus:
	
	addi $t0, $0, 2	#first shift amount to test
	#find less than, but next is not
	add $t6, $0, $0 #counter
	add $t7, $0, $0 #continue or no
	
	#first attempt
	sltu $t7, $a1, $t0	#test if the shift is greater or not
	addi $t6, $t6, 1
	bne $t7, $0, end
	loop:
		sll $t0, $t0, 1	#second attempt
		#divide by first
		sltu $t7, $a1, $t0	#test if the shift is greater or not
		addi $t6, $t6, 1
		beq $t7, $0, loop
	end:
	srl $t0, $t0, 1
	sub $v0, $t6, 1
	sub $t4, $a1, $t0
	
#try 2, 4, 8, 16... until one is less than, but the next is not
#t4 is remainder, $t5 is a counter, t1 is a remainder * first input
sllv $t0, $a0, $v0	#Multiplies by greates shift amount possible

#if remainder loop back modulus
add $t3, $t0, $t3 #partial total
move $a1, $t4
bne $t4,$0, modulus

#result is in $t3

jal load
jal print_eq

#pre: first int t0, operator t1, second int t2, result t3
#post: prints out equation
print_eq:
	
	
	jal print_space
	
	move $a0, $t1
	li $v0, 11
	syscall
	
	jal print_space
	
	move $a0, $t2
	li $v0, 1
	syscall
	
	jal print_space
	
	la $a0, equal
	li $v0, 4
	syscall
	
	jal print_space
	
	move $a0, $t3
	li $v0, 1
	syscall
	 
	la $a0, next
	li $v0, 4
	syscall
	
	jal main

#pre: text string and word adderess of input
#post: prints out that stuff
######################
#DisplayNumb:
#	li $v0, 4
#	syscall
	
#	la $a0, result
#	li $v0, 4
#	syscall
	
#	la $a0, next
#	li $v0, 4
#	syscall
	
#	jr $ra
####################

#pre: nothing
#post: prints a space
print_space:
	la $a0, space
	li $v0 4
	syscall
	jr $ra

#pre: nothing
#post: saves t0 and t2
save:
	sw $t0, temp1
	sw $t1, temp2
	sw $t2, temp3
	sw $t3, result
	
	jr $ra

#pre: nothing
#post: loads t0 and t2
load: 
	lw $t0, temp1
	lw $t1, temp2
	lw $t2, temp3
	jr $ra

#end of program
end_:
