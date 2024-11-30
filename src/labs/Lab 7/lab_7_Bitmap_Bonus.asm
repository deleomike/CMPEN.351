.data

prompt1: .asciiz "Colors: "
prompt_lose: .asciiz "You lose!"
prompt_win: .asciiz "You win!"
prompt_skill: .asciiz "Choose a skill level: 1, 2, 3\n"
prompt_reenter: .asciiz "Incorrect Input"
Panda: .asciiz "Panda.. panda panda.. panda panda panda panda" 	#When called, the string will automatically fix the program
prompt_options: .asciiz "Black: 0\nBlue: 1\nGreen: 2\nRed: 3\nCyan: 4\nPurple: 5\nOrange-Yellow: 6\nWhite: 7\n"

Return: .word 0		#where i save $ra

max: .word 0

length: .word 0	#length of sequence set by skill level
pause_time: .word 0		#time to pause set by skill level

ColorTable:
	.word  0x000000	#black
	.word  0x0000ff	#blue
	.word  0x00ff00	#green
	.word  0xff0000	#red
	.word  0x00ffff	#blue + green = cyan
	.word  0xff00ff	#blue + red = purple
	.word  0xffff00	#green + red = orange-yellow
	.word  0xffffff	#white

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
		
		addi $t2, $v0, -48	#saves user input
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
	addiu $sp, $sp, -8	#set stack pointer
	sw $ra, 0($sp)		#save return
	
	jal Randomize
	move $a0, $v0
	
	rem $a0, $a0, 8		#modulus: random number % 8
	blt $a0, $0, negate	#if the number is negative, make it positive
	j no_negate
	
	negate:
		mul $a0, $a0, -1	#make it positive
	
	no_negate:
	sw $a0, 4($sp)
	
	la $a0, prompt_options	#prints options
	li $v0, 4
	syscall
	
	lw $a0, 4($sp)
	
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
	addiu $sp, $sp, -16	#set stack pointer
	sw $ra, 0($sp)		#save return
	
	
	la $a1, sequence	#loads address of sequence
	mul $a3, $a0, 4		#converts increment to count in words
	add $a1, $a1, $a3	#shifts the sequence pointer $a1, by $a3 number of words
	lw $a0, 0($a1)		#saves the new sequence value to the top of the sequence
	
	sw $a0, 4($sp)		#saves color
	li $a2, 7		#white
	li $a0, 0		#x coord is 1
	li $a1, 15		#y coord is 15
	li $a3, 31		#length is 30
	jal DrawHorzLine
	
	li $a2, 7		#white
	li $a0, 15		#x coord is 1
	li $a1, 0		#y coord is 15
	li $a3, 31		#length is 30
	jal DrawVertLine
	
	jal Randomize
	mul $v0, $v0, -1
	rem $v0, $v0, 4		#0-3 for each box on the screen
	
	lw $a2, 4($sp)		#restore color
	beq $v0, $0, ULeft	#top left
	beq $v0, 1, URight	#top right
	beq $v0, 2, BLeft	#bottom left
	beq $v0, 3, BRight	#bottom right
	
	###!!!! After this was made, something went wrong. LOOK HERE. Directly above and below
	ULeft:
		li $a0, 1	#x coord is 1
		li $a1, 1	#y coord is 1
		j DISP_
	URight:
		li $a0, 17	#x coord is 13
		li $a1, 1	#y coord is 1
		j DISP_
	BLeft:
		li $a0, 1	#x coord is 1
		li $a1, 17	#y coord is 13
		j DISP_
	BRight:
		li $a0, 17	#x coord is 13
		li $a1, 17	#y coord is 13
	DISP_:
	
	sw $a0, 8($sp)		#saves x
	sw $a1, 12($sp)		#saves y
	li $a3, 13	#size is 30
	jal DrawBox
	
	lw $a0, pause_time
	jal Pause
	
	lw $a0, 8($sp)	#loads parameters for current box
	lw $a1, 12($sp)
	jal Erase
	
	lw $ra, 0($sp)	
	addiu $sp, $sp, 8
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
#pre: $a0 is x coord, $a1 is y coord
#post: black screen
Erase:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a2, 0	#color is black
	li $a3, 13	#full screen
	jal DrawBox
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra

#pre: $a0 is x coord (0-31), a1 is y coord (0-31), a2 is color (0-7), a3 is size (1-32)
#post: draws a box
DrawBox:
	addiu $sp, $sp, -24
	sw $ra, 0($sp)
	
	move $s0, $a3	#counter for loop
	##!!!I dont know what $s0 is, it could be the height of box
	BoxLoop:
		sw $a0, 4($sp)
		sw $a1, 8($sp)	#saves parameters
		sw $a2, 12($sp)
		sw $a3, 16($sp)
		sw $s0, 20($sp)
		
		jal DrawHorzLine
		
		lw $a0, 4($sp)
		lw $a1, 8($sp)	#loads parameters
		lw $a2, 12($sp)
		lw $a3, 16($sp)
		lw $s0, 20($sp)
		
		addi $a1, $a1, 1	#increment height by 1 pixel
		
		addi $s0, $s0, -1	#decrement counter by -1
		bne $s0, $0, BoxLoop	#if counter is more than 0 then loop again
	
	lw $ra, 0($sp)	
	addiu $sp, $sp, 24
		
	jr $ra
#pre: $a0 is x coordinate (0-31), $a1 is y coordinate (0-31)
#post: $v0 is converted coordinate returned to address
CalcAddr:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	#address = (x coord * 4) + base + (y coord * 32 * 4)
	
	li $s0, 268697600	#loads base
	sll $a0, $a0, 2	# x coord * 4
	sll $a1, $a1, 7	# y coord * 32 * 4
	
	add $v0, $a0, $a1	#address = x coord * 4 + y coord * 32 * 4
	add $v0, $v0, $s0	#adress = Above + base
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
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
	sw $v1, ($v0)		#stores hex color to the dot address. Makes dot
	
	lw $ra, 4($sp)		#load orignial $ra
	addiu $sp, $sp, 8	#restore $sp
	
	jr $ra
#pre: $a0 is x coord (0-31), $a1 is y coord (0-31), $a2 is color (0-7), $a3 is length
#post: Draws a line Horizontally
DrawHorzLine:
	#(0,0) is top left
	#(31,0) is top right
	#(0,31) is bottom left
	addiu $sp, $sp, -24
	sw $ra, 0($sp)
	li $s0, 0		#set to zero
	loopthrough:
		sw $a0, 4($sp)
		sw $a1, 8($sp)	#saves parameters
		sw $a2, 12($sp)
		sw $a3, 16($sp)
		sw $s0, 20($sp)
		
		jal DrawDot	#draws dot
		
		lw $a0, 4($sp)
		lw $a1, 8($sp)	#loads parameters
		lw $a2, 12($sp)
		lw $a3, 16($sp)
		lw $s0, 20($sp)
		
		addi $a0, $a0, 1	#add 1 to address
		addi $s0, $s0, 1	#add 1 to counter
		
		ble $s0, $a3, loopthrough #if x coord is less than or equal to width
	
	lw $ra, 0($sp)	#load return
	addiu $sp, $sp, 24
	
	jr $ra
	
#pre: $a0 is x coord (0-31), $a1 is y coord (0-31), $a2 is color (0-7), $a3 is length
#post: Draws a line Horizontally
DrawVertLine:
	#(0,0) is top left
	#(31,0) is top right
	#(0,31) is bottom left
	addiu $sp, $sp, -20
	sw $ra, 0($sp)

	loopthrough_:
		sw $a0, 4($sp)
		sw $a1, 8($sp)	#saves parameters
		sw $a2, 12($sp)
		sw $a3, 16($sp)
		
		jal DrawDot	#draws dot
		
		lw $a0, 4($sp)
		lw $a1, 8($sp)	#loads parameters
		lw $a2, 12($sp)
		lw $a3, 16($sp)
		
		addi $a1, $a1, 1	#add 1 to counter
		
		ble $a1, $a3, loopthrough_ #if x coord is less than or equal to width
	
	lw $ra, 0($sp)	#load return
	addiu $sp, $sp, 20
	
	jr $ra


exit:
	
