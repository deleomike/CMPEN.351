add $t0, $0,$0		#initialize t0 = 0
addi $t1, $0, 10	#initialize t1 = 10 

add $t2,$0, $0		#first counter = 0

loop:
	addi $t2, $t2, 1
	
	add $t0, $t0, $t1
	addi $t1,$t1,10
	
	bne $t2, 1000000, loop	#counter will always be ahead