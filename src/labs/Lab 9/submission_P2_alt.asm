.data
	floatArray: .float 0:20
	promptString: .asciiz "Please enter another float:\n"
	lengthString: .asciiz "How many numbers would you like to enter? (2-20)\n"
	sortedString: .asciiz "Here is the sorted list:\n"
	seperator: .asciiz ", "
	averageString: .asciiz "\nThe average of the numbers you entered is:\n"
	wrongNumberString: .asciiz "Please enter a valid number.\n"
.text
main:

	jal getLength						
	move $s0, $v0						
	addi $s1, $0, 0						#current counter
	forInput:						#loop through and get the user input the correct number of times
		beq $s0, $s1, endForInput
		la $a0, promptString
		move $a1, $s1
		jal getValue
		addi $s1, $s1, 1
		j forInput
	endForInput:
	move $a0, $s0
	jal sort						#sort the input
	la $a0, sortedString
	li $v0, 4
	syscall
	addi $s1, $0, 0
	forDisplay:						#loop through and display the sorted array
		beq $s0, $s1, endForDisplay 
		move $a0, $s1
		move $a1, $s0
		jal printListItem
		add $s1, $s1, 1
		j forDisplay
	
	endForDisplay:
	move $a0, $s0						#calculate and display the average
	jal calculateAverage
	la $a0, averageString
	li $v0, 4
	syscall
	li $v0, 2
	syscall
	j exit
##################################################################
#terminates the program
##################################################################	
exit:
	li $v0, 10
	syscall

##################################################################
#asks the user how many numbers they would like to enter
#inputs
#
#outputs
#v0 = number of inputs
##################################################################
getLength:
	#FOR PART ONE THIS IS JUST A FUNCTION STUB THAT RETURNS 5
	la $a0, lengthString
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	blt $v0, 2, incorrectLength
	bgt $v0, 20, incorrectLength
	j correctLength
	incorrectLength:
		la $a0, wrongNumberString
		li $v0, 4
		syscall
		j getLength
	correctLength:
	
	jr $ra
##################################################################	
#Takes in 1 single precision float as user input from the console	
#inputs
#a0 = prompt string for user input
#a1 = current counter (how many inputs already + 1)
##################################################################
getValue:
	li $v0, 4				#prepares the print string service
	syscall					#prints the string
	li $v0, 6				#prepares the read float service
	syscall					#reads a float from the console
	mul $t0, $a1, 4				#these two lines calculate where in the array to store the flaot
	la $t1, floatArray
	add $a1, $t0, $t1
	swc1  $f0, 0($a1)			#stores the flaot in the array
	jr $ra
###################################################################
#sorts the array using bubble sort
#inputs
#a0 = length of the array
#outputs
#
###################################################################
###################################################################
#This algorithm is modified from one I found on stack overflow.
#The algorithm on stack overflow was not intended for floating point
#numbers. I believe that this is significant enough modification
#to justify reuse.
###################################################################
sort:
    	la  $t0, floatArray      		# Copy the base address of your array into $t1
    	mul $a0, $a0, 4
    	add $t0, $t0, $a0    	                           
	outterLoop:                  		# Used to determine when we are done iterating over the Array
    		add $t1, $0, $0         	# $t1 holds a flag to determine when the list is sorted
    		la  $a0, floatArray     	# Set $a0 to the base address of the Array
	innerLoop:                  		# The inner loop will iterate over the Array checking if a swap is needed
   		l.s $f0, 0($a0)			#sets f0 to the current element in the array
   		cvt.s.w $f2, $f0		#performs fp conversion
   		l.s $f1, 4($a0)			#sets f1 to the next element in the array
   		cvt.s.w $f3, $f1		#performs fp conversion
		c.lt.s $f3, $f2			#flag = true if $t3 < t2
		bc1f continue			#branch to continue if flag is false
    		add $t1, $0, 1         	 	# if we need to swap, we need to check the list again
    		s.s $f0, 4($a0)			# store the greater numbers contents in the higher position in the array
    		cvt.s.w $f2, $f0		#perform fp conversion
    		s.s $f1, 0($a0)			#store the lesser numbers contents in the lower position in the array
    		cvt.s.w $f3, $f1		#perform fp conversion
	continue:
    		addi $a0, $a0, 4            	# advance the array to start at the next location from last time
    		bne  $a0, $t0, innerLoop    	# If $a0 != the end of Array, jump back to innerLoop
    		bne  $t1, $0, outterLoop    	# $t1 = 1, another pass is needed, jump back to outterLoop
    	jr $ra
##################################################################
#prints the next item in the list, and a comma if necessary
#inputs
#a0 = current counter
#a1 = length of array
#outputs 
#
##################################################################
printListItem:
	mul $t0, $a0, 4				#calculates how many bytes to look ahead in memory for the sequence
	#this is adjusted by 4 bytes because the sort moves the array bytes
	l.s $f12, floatArray+4($t0)		#grabs the value at the appropriate location in the sequence, and prepares it to be printed
	li $v0, 2				#prepares the print float service
	syscall					#prints the float
	addi $a0, $a0, 1			
	bne $a0, $a1, printSeperator		#unless it is the last item, print a comma
	j printDone				#if it is the last item, no comma
	printSeperator:
		la $a0, seperator		#grab the seperator string
		li $v0, 4			#prepeare the print string service
		syscall				#print the comma
	printDone:
	jr $ra
	
###################################################################
#calculates the average of the input values
#inputs
#a0 = length of array
#outputs
#f12 = average
##################################################################
calculateAverage:
	add $t5, $0, $0					#initialize counter
	forAverage:
		beq $t5, $a0, endForAverage		#if you have looped through the whole array, stop
		mul $t6, $t5, 4				#mulltiply your current counter by 4
		#this is adjusted by 4 because the sort moves the array 4 bytes for some reason
		l.s $f11, floatArray+4($t6)		#put the current value in a fp register
		add.s $f14, $f14, $f11			#keep a running total
		addi $t5, $t5, 1			#increment the counter
		j forAverage				#loop
	endForAverage:
	mtc1 $a0, $f0					#for the dividen
	cvt.s.w $f1, $f0				#perform fp conversion
	div.s $f12, $f14, $f1				#calculate average
	jr $ra
	
