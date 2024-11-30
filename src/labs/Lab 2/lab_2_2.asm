.data				#variables and data
prompt: .ascii "Enter Integers: "	#String

temp: .word 5 	#storing the string

.text	#code

print: la $a0, prompt	#loads string address to $a0
	li $v0, 4	#load syscall number
	syscall		
		
	li $v0, 5	#Gets an integer from user and stores it
	syscall
	
	move $t0, $v0	#copies the number given
	
	sw $t0, temp
	
	#sll $t0, $t0, 4
	sll $a0, $t0, 2		#multiplies by a total of 4. 2^n
	add $a0, $a0, $t0	#adds $t0 to be 'multiplying' by 5
	
	li $v0, 1		#syscall to print integer
	syscall
