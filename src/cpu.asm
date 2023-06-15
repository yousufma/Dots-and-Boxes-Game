# Initialize the game state and include the validation file
.include 	"move.asm"


.data


# Define the game loop subroutine
.text
#.globl computer_turn

# t0= row t1=col t2= direction

# set the row, column, and direction (or placement of line) to 0
computer_turn:
	addi $sp, $sp, -4 
    	sw   $ra, 0($sp)
    	
	li $s0, 0
	li $s1, 0
	li $s2, 0
	
# called after columns have been looped through


	

# calls row_loop after all columns have been iterated

	
	


direction_loop:
	jal validate_move
	beq $s4, 1, return_cpu
	addi $s2, $s2, 1
	beq $s2, 4 column_loop
	j direction_loop


column_loop:
	li $s2, 0
	addi $s1, $s1, 1
	beq $s1, 7, row_loop
	j direction_loop

row_loop:
	li $s1, 0
	addi $s0, $s0, 1
	beq $s0, 7, return_cpu
	j column_loop

return_cpu:
    	lw   $ra, 0($sp)
    	addi $sp, $sp, 4
	jr $ra

	
		
	
