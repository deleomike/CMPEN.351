.data

prompt1: .asciiz "Colors: "
prompt_lose: .asciiz "You lose!"
prompt_win: .asciiz "You win!"
prompt_skill: .asciiz "Choose a skill level: 1, 2, 3\n"
prompt_reenter: .asciiz "Incorrect Input"
Panda: .asciiz "Panda.. panda panda.. panda panda panda panda" 	#When called, the string will automatically fix the program

Return: .word 0		#where i save $ra

max: .word 0

length: .word 0	#length of sequence set by skill level
pause_time: .word 0		#time to pause set by skill level

ColorTable:
	.word 0, 0x000000	#black
	.word 1, 0x0000ff	#blue
	.word 2, 0x00ff00	#green
	.word 3, 0xff0000	#red
	.word 4, 0x00ffff	#blue + green
	.word 5, 0xff00ff	#blue + red
	.word 6, 0xffff00	#green + red
	.word 7, 0xffffff	#white

base: .word 1	#!!!! I don't know what a base is
sequence: .word 0, 0, 0, 0, 0

temp_buffer: .word 0

.text
main:
	jal skill_level
	
	sw $0, max	#max = 0
	lw $t1, max
	start:
	
	
	addi $t1, $t1, 1	#increment max
	
	li $t2, 0	#counter
	blink:
		addi $t2, $t2, 1	#increments counter
		#addiu $t6, $t1, -1	#one less than the max
		beq $t2, $t1, add_element
		j dont_add_element
		add_element:
			jal New_Color
			la $t3, sequence	#loads address of sequence
			mul $t4, $t2, 4		#t2 is increment. t4 is the converted increment byte to word
			add $t3, $t3, $t4	#shifts the sequence pointer $t3, by $t2 number of words
			sw $v0, 0($t3)		#saves the new sequence value to the top of the sequence
		####!!!!!I'm trying to shift the pointer of the sequence by one word, and then saving the new value there
		dont_add_element:
		move $a0, $t2
		jal Display	#prints out the color
		li $a0, 32		#prints a space
		jal Display_Char
		
		blt $t2, $t1, blink	#if counter < max continue to loop
		
		li $a0, 10	#print end of line
		jal Display_Char
	
	li $t7, 0	#counter
	check:
		jal GetInput
		
		move $t2, $v0		#saves user input
		move $a0, $t7		#loads incrememnt to parameter
		jal GetSequence
		move $v0, $v1
		
		addi $t7, $t7, 1	#increment counter
		beq $t2, $v0, same_answer	#if the user has the same answer as the sequence, loop
		j fail			#user does not have right answer
		
		same_answer:
		blt $t7, $t1, check	#if counter < max continue to loop
		li $a0, 10		#prints end of line character
		li $v0, 11		#'
		syscall			#'
		j pass			#user has passed all parts of sequence
		
		
		
	fail:
		la $a0, prompt_lose	#displays losing prompt
		li $v0, 4
		syscall
		j exit
	pass:
		lw $t7, length
		blt $t1, $t7, start
		la $a0, prompt_win	#displays winning prompt
		li $v0, 4
		syscall
		j exit

#pre: nothing
#post: Changes pause time, and adjusts length of sequence. Nothing in return
skill_level:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)	#saves return
	
	j no_error
	
	get_skill:
	la $a0, prompt_reenter	#prints if user entered incorrect input
	li $v0, 4
	syscall
	
	no_error:
	la $a0, prompt_skill	#prompts user for skill level
	li $v0, 4
	syscall
	
	jal GetInput
	
	blt $v0, 49, get_skill	#less than 1
	bgt $v0, 51, get_skill	#greater than 3
	
	beq $v0, 49, easy	#if skill is 1
	beq $v0, 50, medium	#if skill is 2
	beq $v0, 51, hard	#is skill is 3
	
	easy:
		li $t0, 1000	#pause time
		li $t1, 5	#sequence length
		j end_skill
		
	medium:
		li $t0, 500	#pause time
		li $t1, 8	#sequence length
		j end_skill
	hard:
		li $t0, 250	#pause time
		li $t1 11	#sequence length
	
	end_skill:	#prevents overlap between cases
	
	sw $t0, pause_time
	sw $t1, length
	
	li $a0, 10	#print end character
	jal Display_Char
	
	lw $ra, 0($sp)	#restores return
	addiu $sp, $sp, 4
	
	jr $ra
	

#pre: nothing
#post: input is in $v0
GetInput:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)		#saves $ra
	
	li $v0, 12		#get character
	syscall
			
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra	
		
#pre: $a0 is increment of sequence
#post: $v0 is color from sequence
GetSequence:
	addiu $sp, $sp, -4	#set stack pointer
	sw $ra, 0($sp)		#save return
	
	la $s0, sequence	#start of sequence
	mul $a0, $a0, 4		#convert increment from word to byte
	add $s0, $s0, $a0	#push pointer forward by how many $a0 bytes
	
	#li $v0, 90		#load color from that address
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	lw $v1, 4($s0)		#loads color from sequence
	
	jr $ra	
	
#Pre: Nothing
#Post: returns a new random color (1-4) in $v0
New_Color:
	addiu $sp, $sp, -4	#set stack pointer
	sw $ra, 0($sp)		#save return
	
	jal Randomize
	move $a0, $v0
	
	rem $a0, $a0, 4		#modulus: random number % 5
	blt $a0, $0, negate	#if the number is negative, make it positive
	j no_negate
	
	negate:
		mul $a0, $a0, -1	#make it positive
	
	no_negate:
	add $a0, $a0, 49		#put the rand in the range of 1-4
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	move $v0, $a0
	
	jr $ra

#pre: $a0 is character to print
#post: prints
Display_Char:
	addiu $sp, $sp, -4	#set stack pointer
	sw $ra, 0($sp)		#save return
	
	li $v0, 11
	syscall
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra

#pre: $a0 is the increment
#post: prints color
Display:
	addiu $sp, $sp, -4	#set stack pointer
	sw $ra, 0($sp)		#save return
	
	
	la $a1, sequence	#loads address of sequence
	mul $a3, $a0, 4		#converts increment to count in words
	add $a1, $a1, $a3	#shifts the sequence pointer $a1, by $a3 number of words
	lw $a0, 0($a1)		#saves the new sequence value to the top of the sequence
	
	jal Display_Char
	
	lw $a0, pause_time
	jal Pause
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra

#pre: $a0 is id of generator, $a1 is seed for generator
#post: returns random number in $v0
Randomize:
	addiu $sp, $sp, -4	#set stack pointer
	sw $ra, 0($sp)		#save return
	##!!!!!!! I don't know if this works
	li $v0, 40	#set seed
	syscall
	
	li $v0, 30	#get current time in $a0
	syscall	
	
	li $v0, 41	#Returns random number
	syscall
	
	move $v0, $a0
	
	lw $ra, 0($sp)	#load return
	addiu $sp, $sp, 4
	jr $ra
	

#pre: $a0 is number of millseconds to wait
#post: waits
Pause:
	addiu $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	#saves registers used here
	
	move $t0, $a0	#save time argument, time to wait
	
	li $v0, 30
	syscall		#gets time in $a0
	
	move $t1, $a0	#saves start time
	
	loop2:
		syscall
		subu $t2, $a0, $t1	# $t2 is current time - initial time. difference between start and now
		bltu $t2, $t0, loop2	#loop if current time < time to wait
	
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	addiu $sp, $sp, 12
	jr $ra

Erase:
	
	jr $ra
	
DrawBox:
	jr $ra
#pre: $a0 is x coordinate (0-31), $a1 is y coordinate (0-31)
#post: $v0 is converted coordinate returned to address
CalcAddr:
	#address = (x coord * 4) + base + (y coord * 32 * 4)
	lw $t1, 0($a0)	#load x coord
	lw $t2, 0($a1)	#load y coord
	
	lw $t5, base	#loads base
	sll $t1, $t1, 2	# x coord * 4
	sll $t2, $t2, 7	# y coord * 32 * 4
	
	add $t0, $t1, $t2	#address = x coord * 4 + y coord * 32 * 4
	add $t0, $t0, $t5	#adress = Above + base
	
	move $v0, $t0
	
	jr $ra
	
#pre: $a2 is color number (0-7)
#post: returns $v1 as actual hex number to display
GetColor:
	la $t0, ColorTable	#load base
	sll $a2, $a2, 2		#index a2 * 4 is offset. This will be the index through the colortable memory
	
	add $a2, $t0, $a2	#address is base + offset
	lw $v1, 0($a2)		#this is the actual color
	
	jr $ra
	
#pre: $a0 is x coord (0-31), $a1 is y coord (0-31), $a2 is color number (0-7)
#post: draws dot (for now it is just a text)
DrawDot:
	addiu $sp, $sp, -8	#adjust the stack pointer for two words
	sw $ra, 4($sp)		#Store $ra
	sw $a2, 0($sp)		#store $a2
	
	jal CalcAddr		#$v0 will have address for pixel
	lw $a2, 0($sp)		#restore $a2
	sw $v0, 0($sp)		#store $v0 in same spot as $a2 was
	
	jal GetColor		#$v1 will have color for number
	lw $v0, 0($sp)		#restore address of of dot to $v0
	sw $v1, 0($v0)		#stores hex color to the dot address
	
	lw $ra, 4($sp)		#load orignial $ra
	addiu $sp, $sp, 8	#restore $sp
	
	jr $ra
	
exit:
	
