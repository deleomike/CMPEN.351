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
	
	move $a0, $t0		#copies to $a0
	li $v0, 35		#syscall to print in 32 bit binary
	syscall
