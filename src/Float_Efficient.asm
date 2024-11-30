.data

prompt: .asciiz "Enter 5 Floating Point Values:"

array: .float 0,0,0,0,0
disqualify_array: .word 0, 0, 0, 0, 0	#array to hold disqualified elements from

numb: .float 5.0
.text

main:
##GET TO WORK WITH NEGATIVES
##NEEDS TO GET 2 - 20 inputs

la $a0, prompt	#load prompt
li $v0, 4	#string syscall
syscall

la $a0, array	#loads address of array
loop:
	li $v0, 6	#read float, float is in $f0
	syscall
	#jal ConvertToInt	#convert the number
	swc1 $f0, 0($a0)	#store float point in the array at this address
	addi $a0, $a0, 4	#increment by 4
	bne $a0, 268501044, loop	#use $a0 as the address and the counter. 268501040 is the end of the array
	#if the loop runs five times go through

###!!!!PRINT OFF SORTED ARRAY
li $t0, 24
la $t2, disqualify_array
sort:
	subi $t0, $t0, 4
	subi $a0, $a0, 20	#reset pointer to array
	lwc1 $f12, 0($a0)	#assign the first operand
	
	go_through_list:
	#go through list, if it is not less than replace with current place
	lwc1 $f1, 0($a0)
	c.le.s $f12, $f1	#if the current number is less than the one in the list, keep going
	bc1t no_replace			#^
	la $t1, 0($a0)			#save the current location
	#load address of number being put in. This will remember the number is disqualified
	li $s0, 268501040	#load word before disqualified array for offset
	search:
		#if the current best number that is selected is in the disqualified array, do not use it
		addi $s0, $s0, 4	#will start then at first word in disq array
		beq $s0, 268501060, stop_search	#stop the search if it's at the end of the disq array
		lw $t3, 0($s0)		#get that address
		beq $t3, $t1, no_replace	#number has already been given
		bne $t3, $t1, search	#if the addresses are the same, the number has already been disqualified
		stop_search:
	sw $t1, 0($t2)			#Save address of disqualified number to disq_Array
	l.s $f12, 0($t1)		#replace with compared number
	no_replace:
	addi $a0, $a0, 4	#increment by 4
	ble $a0, 268501040, go_through_list	#use $a0 as the address and the counter. 268501040 is the end of the array
	#look into making these two above into a function to reduce lines
	jal print	#this will print the best lowest number
	addi $t2, $t2, 4		#move disq array iterator forward one word
	##REPLACE COUNTER BELOW WITH ITERATOR OF DISQ ARRAY
	bne $t0, 0, sort	#use $a0 as the address and the counter. 268501060 is the end of the array

subi $a0, $a0, 4	#iterate backwards by 4
average:
	#$f2 is load to
	#$f3 is total
	lwc1 $f2, 0($a0)	#load last value of sorted array
	add.s $f3,$f3, $f2	#add load to total
	subi $a0, $a0, 4	#iterate backwards by 4
	bge $a0, 268501024, average	#go through five times
lwc1 $f1, numb
div.s $f12, $f3, $f1	#get the average
jal print		#print
j end
#$f12 is register to print
#prints
##!!!HAS NO PROTECTION AGAINST RECURSION
print:
	li $v0, 2
	syscall
	jr $ra

end:
		
