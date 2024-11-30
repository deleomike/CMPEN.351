.text
DivNumb:

	li $a0, 15	#load inputs
	li $a1, 4
	
	add $v0, $0, $0
	#initially it goes in 0 times
	add $t1, $a1, $0
	#copy $a1 to $t1
	jal chko
	
oloop:  add $t1, $a1, $0
	#divisor multiple starts at 1x
	add $t2, $0, 1
	#initialize temp quotient to 1
	jal chki
	
inloop:  sll $t2, $t2, 1
	#multiply temp quotient by 2
	sll $t1, $t1, 1
	#multiply divisor by 2
	chki:
	sltu $t0, $a0, $t1
	#if remaining dividend is less than div multiple
	beq $t0, $zero, inloop   #fall through to add temp quotient
	addu $v0, $v0, $t2
	#add temp quotient to running
	srl $t1, $t1, 1
	#undo last divisor multiply
	sub $a0, $a0, $t1
	#subtract biggest multiple from dividend
	chko:
	sltu $t0, $a0, $a1
	#set $t0 if $a0 < $a1
	beq $t0, $0, oloop
	#repeat until div is calculated
	
	srl $v0, $v0, 1
	
	move $t3, $v0