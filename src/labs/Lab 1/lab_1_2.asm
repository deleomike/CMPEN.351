add $t0, $zero, $zero		#initialize $t0
addi $t1, $zero, 10		#initialize $t1 = 10

add $t2, $0,$0
loop:
	addi $t2, $t2, 1	#counter
	add $t0, $t0,$t1	#Add t1 to t0
	addi $t1, $t1, 10	#Add 10 to t1
	bne $t2, 5, loop	#do this while $t2 does not equal 5