.data

prompt: .asciiz "Enter First Integer: "

prompt2: .asciiz "Enter Second Integer: "

filename: .asciiz "program1.txt"
data: .word 0

buffer: .byte 48,52,54,54,55,0

array: .space 20

result: .word 1

temp1: .word 5
temp2: .word 5

.text

save: la $a0, prompt	#loads first string address
	li $v0, 4	#Will print prompt
	syscall
	
	li $v0, 5	#recieve user input
	syscall
	
	move $t0, $v0	#copy the input	
	sw $t0, temp1	#save to memory	
	
	la $a0, prompt2	#Load second integer prompt
	li $v0, 4	#syscall prompt
	syscall
	
	li $v0, 5	#recieve second input
	syscall
	
	move $t1, $v0	#copy the input
	sw $t1, temp2	#save to memory
	
	add $t0, $0, $0 #Reset variables
	add $t1, $0, $0
	li $v0, 0
	li $a0, 0
	
	lw $t1, temp1
	lw $t2, temp2
	srlv $t0, $t1, $t2 
	
	lw $a0, temp1	#load first input to a0
	lw $a1,  temp2	#load second input to a1
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

move $a0, $t3	#Assigns result as a0
li $v0, 1	#calls print syscall
syscall





################################################################
#i didn't get the base - 32 conversion to work, i had some trouble with it.
sw $t3, result

lw $t0, result
li $t9, 31
li $t1, 0
li $t2, 0
la $t2, array

and $t3, $t0, $t9
bge $t3, 10, letterchk
add $t1, $t3, 48

j skipto

letterchk:
	add $t1, $t3, 55
	
skipto:
	sb $t1, 5($t2)
	
srl $t0, $t0, 5	
and $t3, $t0, $t9
bge $t3, 10, letterchk1
add $t1, $t3, 48

j skipto1

letterchk1:
	add $t1, $t3, 55
	
skipto1:
	sb $t1, 4($t2)
	
srl $t0, $t0, 5
and $t3, $t0, $t9
bge $t3, 10, letterchk2
add $t1, $t3, 48

j skipto2

letterchk2:
	add $t1, $t3, 55
	
skipto2:
	sb $t1, 3($t2)
	
srl $t0, $t0, 5
and $t3, $t0, $t9
bge $t3, 10, letterchk3
add $t1, $t3, 48

j skipto3

letterchk3:
	add $t1, $t3, 55
	
skipto3:
	sb $t1, 2($t2)
	
srl $t0, $t0, 5
and $t3, $t0, $t9
bge $t3, 10, letterchk4
add $t1, $t3, 48

j skipto4

letterchk4:
	add $t1, $t3, 55
	
skipto4:
sb $t1, 1($t2)

	
srl $t0, $t0, 5
and $t3, $t0, $t9
bge $t3, 10, letterchk5
add $t1, $t3, 48

j skipto5

letterchk5:
	add $t1, $t3, 55
	
skipto5:
	sb $t1, ($t2)
####################################################

la $a0, array
li $v0, 4
syscall

file_open:
    li $v0, 13	#open file
    la $a0, filename	#filename
    li $a1, 1	#flag, read
    li $a2, 0	#no mode
    syscall  # File descriptor gets returned in $v0
file_write:
    move $a0, $v0  # Syscall 15 required file descriptor in $a0
    li $v0, 15		#write
 
    	
   	 la $a1, 0($t2)	#what to write
   	 li $a2, 16	 	#buffer
    	#lw $a3, 0($t2)	#what to write
    	#subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
   	 syscall
 
 
file_close:
    li $v0, 16  # $a0 already has the file descriptor
    syscall

