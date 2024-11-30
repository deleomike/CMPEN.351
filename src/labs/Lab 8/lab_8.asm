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

#Circle_Array: .word 50, 44, 40, 38, 35, 33, 31, 29, 27, 26, 24, 23, 22, 20, 19, 18, 17, 16, 15, 13, 13 12, 11, 10, 10,9, 8, 8, 7,7, 6,6, 5,5, 4,4,4, 3,3, 2,2,2,2,1,1,1,1,1,1,0,0,0,0,0,0
		#Second Quadrant. top distance = 56 - Distance from x axis 

Circle_Array: .word  30, 28, 28, 28, 26, 24, 24, 24,20, 20,20, 19,19,19,19, 18,18,18,17,17,15
	
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
	li $a1, 120		#y coord is 15
	li $a3, 248		#length is 30
	jal DrawHorzLine
	
	li $a2, 7		#white
	li $a0, 120		#x coord is 1
	li $a1, 0		#y coord is 15
	li $a3, 248		#length is 30
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
		li $a0, 8	#x coord is 1
		li $a1, 8	#y coord is 1
		j DISP_
	URight:
		li $a0, 136	#x coord is 13
		li $a1, 8	#y coord is 1
		j DISP_
	BLeft:
		li $a0, 8	#x coord is 1
		li $a1, 136	#y coord is 13
		j DISP_
	BRight:
		li $a0, 136	#x coord is 13
		li $a1, 136	#y coord is 13
	DISP_:
	
	sw $a0, 8($sp)		#saves x
	sw $a1, 12($sp)		#saves y
	li $a3, 25	#size is 14
	jal DrawBox
	
	#BEEP
	jal Randomize	#this section gets a random number, and turns it into 0-127
	mul $v0, $v0, -1
	rem $v0, $v0, 128
	move $a0, $v0	
	li $a1, 100	#time in millseconds
	li $a2, 1
	li $a3, 100
	li $v0, 31
	syscall
	####
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

#pre: $a0 is x coord (0-255), a1 is y coord (0-255), a2 is color (0-7), a3 is size (1-256)
#post: draws a circle
DrawBox:
	addiu $sp, $sp, -36
	sw $ra, 0($sp)
	
	li $s0, 0	#counter for loop
	la $s1, Circle_Array	#loads address of array distance value
	
	sw $a0, 28($sp)	#saves original x address
	sw $a1, 32($sp)	#saves original y address
	#xcoord is top left as if it were a box. Same with respect to ycoord
	
	#!!!!!! USE THIS SECTION FOR INSTRUCTIONS
	#top of circle is 56 -(distance to axis )
	#bottom of circle is 56 - ( distance to axis)
	#For first half, start y coord at top of circle
	#then double the distance used
	
	BoxLoopThirdSecondQuad:
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a2, 12($sp)
		sw $a3, 16($sp)		#save parameters
		sw $s0, 20($sp)
		sw $s1, 24($sp)
		
		
		#li $s0, 56		#being used as a temp to offset the measurements of the circle. 56 from axis
		lw $s1, 0($s1)		#being used as a temp to get current distance
		li $s0, 31		#offset 56
		sub $s1, $s0, $s1	#56 - distance
		move $a1, $s1		#move the distance from axis to y coord
		li $s0, 122		#offset for box cooordinate system
		sub $a1, $s0, $a1 		#adjust the distance from axis to box coordinate system
		mul $a3, $s1, 2		#distance is doubled for top and bottom
		
		
		
		jal DrawVertLine
		
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $a2, 12($sp)
		lw $a3, 16($sp)		#load parameters
		lw $s0, 20($sp)
		lw $s1, 24($sp)
		lw $s2, 28($sp)
		
		addi $s1, $s1, 4	#moves to next distance (word)
		addi $a0, $a0, 1	#increments x coord by 1
		addi $s0, $s0, 1		#increment counter
		
		bne $s0, 14, BoxLoopThirdSecondQuad	#if the counter has not moved past the quadrant
	#since the address of the circle_array is now at the end, I can do the fourth quadrant, and work backwards on the array
	li $s0, 0		#reset counter
	BoxLoopFourthFirstQuad:
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a2, 12($sp)
		sw $a3, 16($sp)		#save parameters
		sw $s0, 20($sp)
		sw $s1, 24($sp)
		
		lw $s1, 0($s1)		#being used as a temp to get current distance
		li $s0, 31		#offset 56
		sub $s1, $s0, $s1	#56 - distance
		move $a1, $s1		#move the distance from axis to y coord
		li $s0, 122		#offset for box cooordinate system
		sub $a1, $s0, $a1 		#adjust the distance from axis to box coordinate system
		mul $a3, $s1, 2		#distance is doubled for top and bottom
		
		jal DrawVertLineReverse
		
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $a2, 12($sp)
		lw $a3, 16($sp)		#load parameters
		lw $s0, 20($sp)
		lw $s1, 24($sp)
		
		subi $s1, $s1, 4	#moves to previous distance (word)
		addi $s0,$s0,1		#increment counter
		addi $a0, $a0, 1	#increment x coord by 1
		
		bne $s0, 14, BoxLoopFourthFirstQuad
	
	lw $a0, 28($sp)	#x coord
	lw $a1, 32($sp)	#loads original y coord
	la $a2, Test1	#numbers
	la $a2, 4($a2)
	jal OutText
		
	lw $ra, 0($sp)	
	addiu $sp, $sp, 36
		
	jr $ra
#pre: $a0 is x coordinate (0-31), $a1 is y coordinate (0-31)
#post: $v0 is converted coordinate returned to address
CalcAddr:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	#address = (x coord * 4) + base + (y coord * 32 * 4)
	
	li $s0, 268697600	#loads base
	sll $a0, $a0, 2	# x coord * 4
	sll $a1, $a1, 10	# y coord * 256 * 4
	
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
	
#pre: $a0 is x coord (0-255), $a1 is y coord (0-255), $a2 is color number (0-7)
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
#pre: $a0 is x coord (0-255), $a1 is y coord (0-255), $a2 is color (0-7), $a3 is length
#post: Draws a line Horizontally
DrawHorzLine:
	#(0,0) is top left
	#(255,0) is top right
	#(0,255) is bottom left
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
	
#pre: $a0 is x coord (0-255), $a1 is y coord (0-255), $a2 is color (0-7), $a3 is length
#post: Draws a line Vertically Top - Down
DrawVertLine:
	#(0,0) is top left
	#(31,0) is top right
	#(0,31) is bottom left
	addiu $sp, $sp, -24
	sw $ra, 0($sp)
	li $s0, 0	#counter
	loopthrough_:
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
		
		addi $a1, $a1, 1	#add 1 to coord
		addi $s0, $s0, 1	#add 1 to counter
		
		ble $s0, $a3, loopthrough_ #if x coord is less than or equal to width
	
	lw $ra, 0($sp)	#load return
	addiu $sp, $sp, 24
	
	jr $ra
	
##!!! MAY NOT WORK
#pre: $a0 is x coord (0-255), $a1 is y coord (0-255), $a2 is color (0-7), $a3 is length
#post: Draws a line Vertically Down - Top
DrawVertLineReverse:
	#(0,0) is top left
	#(31,0) is top right
	#(0,31) is bottom left
	addiu $sp, $sp, -28
	sw $ra, 0($sp)
	move $t0, $a1		#temp save the original value
	add $a1, $a1, $a3	#add length to
	li $s0, 0		#counter
	
	loopthrough_R:
		sw $a0, 4($sp)
		sw $a1, 8($sp)	#saves parameters
		sw $a2, 12($sp)
		sw $a3, 16($sp)
		sw $t0, 20($sp)
		sw $s0, 24($sp)
		
		jal DrawDot	#draws dot
		
		lw $a0, 4($sp)
		lw $a1, 8($sp)	#loads parameters
		lw $a2, 12($sp)
		lw $a3, 16($sp)
		lw $t0, 20($sp)
		lw $s0, 24($sp)
		
		subi $a1, $a1, 1	#add 1 to coord
		addi $s0, $s0, 1	#add 1 to counter
		
		ble $s0, $a3, loopthrough_R #if y coord is greater than or equal to height
	
	lw $ra, 0($sp)	#load return
	addiu $sp, $sp, 28
	
	jr $ra
	
        .data

        .word   0 : 40

Stack:



Colors: .word   0x000000        # background color (black)

        .word   0xffffff        # foreground color (white)



DigitTable:

        .byte   ' ', 0,0,0,0,0,0,0,0,0,0,0,0

        .byte   '0', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e

        .byte   '1', 0x38,0x78,0xf8,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18

        .byte   '2', 0x7e,0xff,0x83,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc1,0xff,0x7e

        .byte   '3', 0x7e,0xff,0x83,0x03,0x03,0x1e,0x1e,0x03,0x03,0x83,0xff,0x7e

        .byte   '4', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7f,0x03,0x03,0x03,0x03,0x03

        .byte   '5', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0x7f,0x03,0x03,0x83,0xff,0x7f

        .byte   '6', 0xc0,0xc0,0xc0,0xc0,0xc0,0xfe,0xfe,0xc3,0xc3,0xc3,0xff,0x7e

        .byte   '7', 0x7e,0xff,0x03,0x06,0x06,0x0c,0x0c,0x18,0x18,0x30,0x30,0x60

        .byte   '8', 0x7e,0xff,0xc3,0xc3,0xc3,0x7e,0x7e,0xc3,0xc3,0xc3,0xff,0x7e

        .byte   '9', 0x7e,0xff,0xc3,0xc3,0xc3,0x7f,0x7f,0x03,0x03,0x03,0x03,0x03

        .byte   '+', 0x00,0x00,0x00,0x18,0x18,0x7e,0x7e,0x18,0x18,0x00,0x00,0x00

        .byte   '-', 0x00,0x00,0x00,0x00,0x00,0x7e,0x7e,0x00,0x00,0x00,0x00,0x00

        .byte   '*', 0x00,0x00,0x00,0x66,0x3c,0x18,0x18,0x3c,0x66,0x00,0x00,0x00

        .byte   '/', 0x00,0x00,0x18,0x18,0x00,0x7e,0x7e,0x00,0x18,0x18,0x00,0x00

        .byte   '=', 0x00,0x00,0x00,0x00,0x7e,0x00,0x7e,0x00,0x00,0x00,0x00,0x00

        .byte   'A', 0x18,0x3c,0x66,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3

        .byte   'B', 0xfc,0xfe,0xc3,0xc3,0xc3,0xfe,0xfe,0xc3,0xc3,0xc3,0xfe,0xfc

        .byte   'C', 0x7e,0xff,0xc1,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc1,0xff,0x7e

        .byte   'D', 0xfc,0xfe,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xfe,0xfc

        .byte   'E', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xff,0xff

        .byte   'F', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xc0,0xc0

# add additional characters here....

# first byte is the ascii character

# next 12 bytes are the pixels that are "on" for each of the 12 lines

        .byte    0, 0,0,0,0,0,0,0,0,0,0,0,0









#  0x80----  ----0x08

#  0x40--- || ---0x04

#  0x20-- |||| --0x02

#  0x10- |||||| -0x01

#       ||||||||

#       84218421



#   1   ...xx...      0x18

#   2   ..xxxx..      0x3c

#   3   .xx..xx.      0x66

#   4   xx....xx      0xc3

#   5   xx....xx      0xc3

#   6   xx....xx      0xc3

#   7   xxxxxxxx      0xff

#   8   xxxxxxxx      0xff

#   9   xx....xx      0xc3

#  10   xx....xx      0xc3

#  11   xx....xx      0xc3

#  12   xx....xx      0xc3







Test1:  .asciiz "0123456789"

Test2:  .asciiz "+ - * / ="

Test3:  .asciiz "ABCDEF"



        .text


        la      $sp, Stack



        li      $a0, 1          # some test cases

        li      $a1, 2

        la      $a2, Test1

        jal     OutText



        li      $a0, 1

        li      $a1, 18

        la      $a2, Test2

        jal     OutText



        li      $a0, 1

        li      $a1, 34

        la      $a2, Test3

        jal     OutText



        li      $v0, 10         # program exit

        syscall





# OutText: display ascii characters on the bit mapped display

# $a0 = horizontal pixel co-ordinate (0-255)

# $a1 = vertical pixel co-ordinate (0-255)

# $a2 = pointer to asciiz text (to be displayed)

OutText:

        addiu   $sp, $sp, -24

        sw      $ra, 20($sp)



        li      $t8, 1          # line number in the digit array (1-12)

_text1:

        la      $t9, 0x10040000 # get the memory start address

        sll     $t0, $a0, 2     # assumes mars was configured as 256 x 256

        addu    $t9, $t9, $t0   # and 1 pixel width, 1 pixel height

        sll     $t0, $a1, 10    # (a0 * 4) + (a1 * 4 * 256)

        addu    $t9, $t9, $t0   # t9 = memory address for this pixel



        move    $t2, $a2        # t2 = pointer to the text string

_text2:

        lb      $t0, 0($t2)     # character to be displayed

        addiu   $t2, $t2, 1     # last character is a null

        beq     $t0, $zero, _text9



        la      $t3, DigitTable # find the character in the table

_text3:

        lb      $t4, 0($t3)     # get an entry from the table

        beq     $t4, $t0, _text4

        beq     $t4, $zero, _text4

        addiu   $t3, $t3, 13    # go to the next entry in the table

        j       _text3

_text4:

        addu    $t3, $t3, $t8   # t8 is the line number

        lb      $t4, 0($t3)     # bit map to be displayed



        sw      $zero, 0($t9)   # first pixel is black

        addiu   $t9, $t9, 4



        li      $t5, 8          # 8 bits to go out

_text5:

        la      $t7, Colors

        lw      $t7, 0($t7)     # assume black

        andi    $t6, $t4, 0x80  # mask out the bit (0=black, 1=white)

        beq     $t6, $zero, _text6

        la      $t7, Colors     # else it is white

        lw      $t7, 4($t7)

_text6:

        sw      $t7, 0($t9)     # write the pixel color

        addiu   $t9, $t9, 4     # go to the next memory position

        sll     $t4, $t4, 1     # and line number

        addiu   $t5, $t5, -1    # and decrement down (8,7,...0)

        bne     $t5, $zero, _text5



        sw      $zero, 0($t9)   # last pixel is black

        addiu   $t9, $t9, 4

        j       _text2          # go get another character



_text9:

        addiu   $a1, $a1, 1     # advance to the next line

        addiu   $t8, $t8, 1     # increment the digit array offset (1-12)

        bne     $t8, 13, _text1



        lw      $ra, 20($sp)

        addiu   $sp, $sp, 24

        jr      $ra




exit:
	