.data 

Int1: .byte 0:80
Int2: .byte 0:80
Op: .word 1
Result: .byte 0:80

temp_int1:	.word 1
temp_int2:	.word 1
Result_temp: 	.word 1

Return: .word 1

Remainder: .word 1

temp_buffer: .byte 0:80

nothing: .asciiz ""

prompt1: .asciiz "\nEnter First Integer: "
prompt2: .asciiz "Enter Operator: "
prompt3: .asciiz "\nEnter Second Integer: "
error: .asciiz "You F*cked Up" 


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

la $ra, case	#TEMPORTARY, THIS SHOULD GO TO DISPLAY NUMB
beq $v1, 42, MultNumb
beq $v1, 43, AddNumb
beq $v1, 45, SubNumb
beq $v1, 47, DivNumb


#catches the user if they submit an incorrect operator
la $a0, error
li $v0, 4
syscall
j main

case:


##Revise DisplayNumb to be called from these phrases, and have the calculations return to here to print
	la $a0, nothing
	li $a2, 0
	la $a1, Int1		#loads first int
	jal DisplayNumb
	
	li $a0, 32	#space in ASCII
	jal DisplayOther
	
	#operator
	move $a0, $v1
	jal DisplayOther
	
	li $a0, 32	#space in ASCII
	jal DisplayOther
	
	la $a0, nothing
	la $a1, Int2	#prints second int
	jal DisplayNumb
	
	li $a0, 32	#space in ASCII
	jal DisplayOther
	
	
	li $a0, 61	#equal char
	jal DisplayOther
	
	li $a0, 32	#space in ASCII
	jal DisplayOther
	
	la $a0, nothing
	la $a2,1	#load option to truncate
	la $a1, Result
	jal DisplayNumb



j main
#pre: $a0 is string to print, $a1 is place to store input
#Post: stores input at $a1 address
GetInput:
	li $v0, 4	#Prints string
	syscall
	
	la $a0, 0($a1)	#place to store string
	li $a1, 80		#size
	li $v0, 8	#reads input
	syscall
	
	#!!!!!!Check where the memory is being saved from convert
	
	#pre: $a0 is pointed to string with input
	convert:
	li $t0, 0
	la $a1, 0($a0)
	
	while:
		lb  $t1, 0($a0)		#load incremental byte
		addiu $a0, $a0, 1	#advance pointer
		
		
		#if character is <cr> or null
		#break out
		li $t2, 0xA
		beq $t1, $t2, no_dec	#<cr> check
		beqz $t1, no_dec		#Null check
		
		#if character is '.'
		#break out
		beq $t1, 46, decimal
			li $s0, 47	#iterator for checking the range of the character
			while1:
				#compare character
				#if it is not within range, error
				addi $s0, $s0, 1
				beq $t1, $s0, change	#converts if it is within 0-9
				bne $s0, 57, while1	#returns to while1 if still between 0-9
			
			j error_		#character is not within range of 0-9
			change:
				subi $t3, $t1, 48	#converts to 0-9 Decimal from 48-57 ASCII
		
		li $s0, 10
		mul $t0, $t0, $s0	#multiply by 10, to shift it one decimal to the left
		
		add $t0, $t0, $t3	#add next number
		
		j while
		
		
	error_:
		la $a0, error	#loads error message
		li $v0, 4	#prints string
		syscall
		
		jr $ra
	
	no_dec:	#no decimal, no cents
		mul $t0, $t0, 100	#move to the left twice to accommodate decimal
		sw $t0, 0($a1) #stores number
		jr $ra
		
	
	decimal:#decimal has been hit
		
		mul $t0, $t0, 100	#moves to the left twice to accommodate decimal
		
		
		
		lb $t1, 0($a0)	#load next character
		addiu $a0, $a0, 1	#advance pointer
			li $s0, 47	#iterator for checking the range of the character
			while2:
				#compare character
				#if it is not within range, error
				addi $s0, $s0, 1
				beq $t1, $s0, change1	#converts if it is within 0-9
				bne $s0, 57, while2	#returns to while1 if still between 0-9
			
			j error_		#character is not within range of 0-9
			change1:
				subi $t3, $t1, 48	#converts to 0-9 Decimal from 48-57 ASCII
		li $s0, 10
		mul $s0, $t3, $s0	#tens digit, mul by 10
		add $t0, $t0, $s0	#add to dollar amount
		################# Hundreths Place
		lb $t1, 0($a0)	#load next character
		addiu $a0, $a0, 1	#advance pointer
			li $s0, 47	#iterator for checking the range of the character
			while3:
				#compare character
				#if it is not within range, error
				addi $s0, $s0, 1
				beq $t1, $s0, change2	#converts if it is within 0-9
				bne $s0, 57, while3	#returns to while1 if still between 0-9
			
			j error_		#character is not within range of 0-9
			change2:
				subi $t3, $t1, 48	#converts to 0-9 Decimal from 48-57 ASCII
		li $s0, 1
		mul $s0, $t3, $s0	#tens digit, mul by 10
		add $t0, $t0, $s0	#add to dollar amount
		
		
		#!!!!!!!! Add new Line?
		
		
		sw $t0, 0($a1)
		
	#lw $t0, 0($a0)
	#sw $t0, 0($a2)	#stored input
	
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
	sw $ra, Return	#saves return
	lw $t1, 0($a0)
	lw $t2, 0($a1)
	add $t0, $t1, $t2		#adds the two integers
	sw $t0, 0($a2)		#stores the result from $t0
	
	la $a0, Int1	#loads first int
	li $a1, 43	#loads operator ASCII value
	la $a2, Int2	#loads second int
	la $a3, Result	#loads result
	
	#jal DisplayNumb
	
	lw $ra, Return	#recovers return
	jr $ra

#pre: a0 points to first int, a1 points to second int, a2 points to result
#post: subtracts a0 - a1 = a2, store to result
SubNumb:
	sw $ra, Return	#saves return
	lw $t1, 0($a0)
	lw $t2, 0($a1)
	sub $t0, $t1, $t2		#subtracts first from second
	sw $t0, 0($a2)			#stores result
	
	#print
	la $a0, Int1	#loads first int
	li $a1, 45	#loads operator ASCII value
	la $a2, Int2	#loads second int
	la $a3, Result	#loads result
	
	#jal DisplayNumb
	
	lw $ra, Return	#loads return
	jr $ra

#pre: a0 points to first int, a1 points ti second int, a2 points to result
#post: multiplies inputs, store to result
MultNumb:
	sw $ra, Return	#saves return
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
	
	lw $ra, Return
	jr $ra

DivNumb:
	sw $ra, Return	#saves return
	
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
	sw $a0, Remainder
	
	la $a0, Int1	#loads first int
	li $a1, 47	#loads operator ASCII value
	la $a2, Int2	#loads second int
	la $a3, Result	#loads result
	
	lw $ra, Return	#loads return
	jr $ra
	

#pre: $a0 is pointed to string, $a1 is pointed to int address, $a2 is optional truncation
#post: prints string + equation
DisplayNumb:
	sw $ra, -4($sp)	#saves ra to one spot before on stack
	la $ra, DisplayNumb
	sw $ra, 0($sp)	#if remainder is called, then it will return to this function
	la $ra, noremainder	#no remainder (boolean true remainder, false no remainder continue)
	lw $t0, 0($a1)	#loads integer
	
	li $t1, 100
	beq $a2, 1, trunc	#1 to truncate, 0 to not
	j continue	#not truncating
	trunc:
	beq $v1, 42, adjustMult	#adjust multiple
	beq $v1, 47, adjustDiv	#adjust divide
	j continue
	
	adjustMult:
		div $t0, $t0, $t1
		#adjusts for multiplication (having two extra spaces)
		j continue
	adjustDiv:
		mul $t0, $t0, $t1
		#adjusts for division (having two less spaces)
		la $a1, Remainder	#loads remainder variable
		la $ra, remainder	#loads remainder function
	
	continue:
	div $t2, $t0, $t1	#dollars
	rem $t3, $t0, $t1	#cents
	
		
	
	#######Dollars
	li $v0, 4	#prints string
	syscall
	
	move $a0, $t2
	li $v0, 1
	syscall		#prints dollars
	
	li $a0, 46
	li $v0, 11
	syscall		#prints period
	
	

	
	######Cents
	li $t1, 10
	
	div $t4, $t3, $t1	#tens digit
	rem $t5, $t3, $t1	#hundreths digit
	
	move $a0, $t4
	li $v0, 1
	syscall		#prints cents tens place
	
	move $a0, $t5
	li $v0, 1
	syscall		#prints cents hundreths place
	
	move $a0, $a1
	jr $ra
	
	noremainder:
	lw $ra, -4($sp)	#loads return
	jr $ra
	

#pre: $a0 is character
#post prints character
DisplayOther:
	li $v0, 11	#prints out input
	syscall
	
	jr $ra

#Helper function prints out remainder for division [DisplayNumb]
remainder:
	la $ra, noremainder
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	li $a0, 82	#prints R in ASCII
	li $v0, 11
	syscall
	
	li $a0, 32	#space in ASCII
	li $v0, 11
	syscall
	
	#Subroutine taken from DisplayNumb
	subroutine:
	lw $t0, 0($a1)
	li $t1, 100
	div $t2, $t0, $t1
	rem $t3, $t0, $t1
	#############
	move $a0, $t2
	li $v0, 1
	syscall		#prints dollars
	
	li $a0, 46
	li $v0, 11
	syscall		#prints period
	############
	li $t1, 10
	
	div $t4, $t3, $t1	#tens digit
	rem $t5, $t3, $t1	#hundreths digit
	
	move $a0, $t4
	li $v0, 1
	syscall		#prints cents tens place
	
	move $a0, $t5
	li $v0, 1
	syscall		#prints cents hundreths place
	
	
	jr $ra

end_:
