.text
lui $t0, 0x8000
addi $t0, $t0, -1
#overflow

lui $t0,0x1004
sw $0, 1($t0)
#allignment

li $t0, 0


.ktext 0x80000180

move $k0, $a0
move $k1, $v0		#save regs

mfc0 $a0, $14		#how do i set PC to $13
addi $a0, $a0, 4
mtc0 $a0, $14


eret


