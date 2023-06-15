.include 	"board.asm"


.data
row_error_msg: .asciiz "Invalid input. Choose a row between 0 and 6 inclusive.\n"
column_error_msg: .asciiz "Invalid input. Choose a column between 0 and 6 inclusive.\n"
line_error_msg: .asciiz "Invalid input. Choose a direction between 0 and 3 inclusive. (0:Up, 1:Right, 2:Down, 3:Left).\n"
line_marked_msg: .asciiz "This line was already marked. Try again.\n"


.text
#.globl validate_move

validate_move:
	addi $sp, $sp, -4 
    	sw   $ra, 0($sp)
    	# Check if row is between 0 and 6 inclusive
    	bltz $s0, invalid_row
    	li 	$t0, 6
    	bgt $s0, $t0, invalid_row

    	# Check if column is between 0 and 6 inclusive
    	bltz 	$s1, invalid_column
    	li 	$t0, 6
    	bgt 	$s1, $t0, invalid_column

    	# Check if direction is between 0 and 3 inclusive
    	bltz 	$s2, invalid_line
    	li 	$t0, 3
    	bgt 	$s2, $t0, invalid_line

    	# Check if the selected line is already marked true
    	jal 	check_if_placed
    	
    	
    	beqz 	$s4, invalid_move	
    	
    	lw   $ra, 0($sp) 
    	addi $sp, $sp, 4   	
    	jr 	$ra

invalid_move:
	# Don't print a message if it's the CPU's turn. We may be overwriting the return address here.
	bnez $s7, return_validation
    	# Print error message and return 0
    	la $a0, line_marked_msg # if the line is already marked
    	li $v0, 4
    	syscall
    	move $v0, $zero
return_validation:
	li $s4, 0
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
    	jr $ra
invalid_row:
	la $a0, row_error_msg
	li $v0, 4
	syscall
	move $v0, $zero
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
invalid_column:
	la $a0, column_error_msg
	li $v0, 4
	syscall
	move $v0, $zero
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
invalid_line:
	la $a0, line_error_msg # if the direction input is out of bounds
	li $v0, 4
	syscall
	move $v0, $zero
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
