.data

prompt: .asciiz "Enter Floating Point Values:"

array: .float 0,0,0,0,0		,0,0,0,0,0	,0,0,0,0,0	,0,0,0,0,0	#up to 20 float
disqualify_array: .word 0,0,0,0,0		,0,0,0,0,0	,0,0,0,0,0	,0,0,0,0,0	#array to hold disqualified elements from

prompt_total: .asciiz "How many values? 2 -> 20"
numb: .float 5.0	#number to average with
.text

main:
##GET TO WORK WITH NEGATIVES
##NEEDS TO GET 2 - 20 inputs

la $a0, prompt_total	#number of float to get
jal print_string
li $v0, 5
syscall

sw $v0, numb		#save number of float
mtc1 $v0, $f4		#move to cop. 1
cvt.s.w $f4, $f4	#convert
mul $s1, $v0, 4		#s1 now holds number of values * 4 for memory access purposes (# - > words)
addi $s2, $s1, 268501024	#add numb of float to start of array + 4 to know how much to use. $s2 will be end of array
addi $s3, $s1, 268501104	#add numb of float to start of disq array + 4to know how much to use. $s3 will be end of disq array

la $a0, prompt	#load prompt
jal print_string

#12 lines

la $a0, array	#loads address of array
loop:
	li $v0, 6	#read float, float is in $f0
	syscall
	#jal ConvertToInt	#convert the number
	
	swc1 $f0, 0($a0)	#store float point in the array at this address
	addi $a0, $a0, 4	#increment by 4
	bne $a0, $s2, loop	#use $a0 as the address and the counter. 268501040 is the end of the array
	#if the loop runs five times go through

#18 lines
#i recieved this from Matt, who recieved this from Mat Partin, who recieved this from stack overflow
sort:
    	la  $t0, array      		# Copy the base address of your array into $t1
    	add $t0, $t0, $s1   	                           
	outterLoop:                  		# Used to determine when we are done iterating over the Array
    		add $t1, $0, $0         	# $t1 holds a flag to determine when the list is sorted
    		la  $s1, array     	# Set $a0 to the base address of the Array
	innerLoop:                  		# The inner loop will iterate over the Array checking if a swap is needed
   		l.s $f0, 0($s1)			#sets f0 to the current element in the array
   		cvt.s.w $f2, $f0		#performs fp conversion
   		l.s $f1, 4($s1)			#sets f1 to the next element in the array
   		cvt.s.w $f3, $f1		#performs fp conversion
		c.lt.s $f3, $f2			#flag = true if $t3 < t2
		bc1f continue			#branch to continue if flag is false
    		add $t1, $0, 1         	 	# if we need to swap, we need to check the list again
    		s.s $f0, 4($s1)			# store the greater numbers contents in the higher position in the array
    		cvt.s.w $f2, $f0		#perform fp conversion
    		s.s $f1, 0($s1)			#store the lesser numbers contents in the lower position in the array
    		cvt.s.w $f3, $f1		#perform fp conversion
	continue:
    		addi $s1, $s1, 4            	# advance the array to start at the next location from last time
    		bne  $a0, $t0, innerLoop    	# If $a0 != the end of Array, jump back to innerLoop
    		bne  $t1, $0, outterLoop    	# $t1 = 1, another pass is needed, jump back to outterLoop 


##Attempted more efficient method using swapping
#39 lines
no_print:

la $a0, array	#iterate backwards by 4
average:
	#$f2 is load to
	#$f3 is total
	lwc1 $f12, 0($a0)	#load last value of sorted array
	jal print
	add.s $f3,$f3, $f12	#add load to total
	addi $a0, $a0, 4	#iterate backwards by 4
	ble $a0, $s2, average	#go through five times
#$f4 has the number converted
div.s $f12, $f3, $f4	#get the average
la $ra, end		#program will go to print, then jr $ra to end
#$f12 is register to print
#prints

#45 lines

##!!!HAS NO PROTECTION AGAINST RECURSION
print:
	li $v0, 2
	syscall
	jr $ra
#$a0 is register to print
#prints
##!!!HAS NO PROTECTION AGAINST RECURSION
print_string:
	li $v0, 4
	syscall
	jr $ra

end:
		
#51 lines
