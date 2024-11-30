.data

	array: .space 16
	
.text

li $s0, 0
li $s1, 4
li $s2, 8
li $s3, 12
li $s4, 16
li $s5, 20

li $t0, 0

sw $s1, array($t0)
addi $t0, $t0, 4
sw $s2, array($t0)
li $t0, 8
sw $s3, array($t0)

li $t0, 0

li $v0, 1
while:
	beq $t0, 16, end_
	lw $t6, array($t0)
	addi $t0, $t0, 4
	move $a0, $t6
	syscall
	j while


end_: