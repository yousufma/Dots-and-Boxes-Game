.include 	"validation.asm"

.data
prompt_row: 	.asciiz "Enter row (0-6): "
prompt_col: 	.asciiz "Enter column (0-6): "
prompt_dir: 	.asciiz "Enter direction (0: top, 1: right, 2: bottom, 3: left): "

.text
#.globl make_move

make_move:
	addi $sp, $sp, -4 
    	sw   $ra, 0($sp)
    	# Get user input for the cell row and column
    	la 	$a0, prompt_row
    	li 	$v0, 4
    	syscall
    	li 	$v0, 5
    	syscall
    	move 	$s0, $v0 # Row

    	la 	$a0, prompt_col
    	li 	$v0, 4
    	syscall
    	li 	$v0, 5
    	syscall
    	move 	$s1, $v0 # Column

    	# Get user input for the line direction
    	la 	$a0, prompt_dir
    	li 	$v0, 4
    	syscall
    	li 	$v0, 5
    	syscall
    	move 	$s2, $v0 # Direction

    	# Call the Validation file to check if the move is valid
    	jal 	validate_move
    	
    	lw   $ra, 0($sp)
    	addi $sp, $sp, 4
    	# Return from make_move
    	jr 	$ra
