.include 	"cpu.asm"
.data
player_name:   	.asciiz "Player"
cpu_name:   	.asciiz "CPU"
game_over_msg:	.asciiz	"Game over.\n"
user_score_msg: .asciiz	"User score: "
cpu_score_msg:  .asciiz	"CPU score: "
win_msg:	.asciiz	"\nYou win! :D"
lose_msg:	.asciiz	"\nYou lose. :("



.text
.globl main
main:
    	# Initialize game variables
    	li $t0, 0
    	li $s3, 0            # Number of completed cells
    	li $s5, 0            # Player score
    	li $s6, 0            # CPU score
    	li $s7, 0            # Current player (0:Player, 1:CPU)

    	# Print the initial board

game_loop:
	# End the game if all boxes are filled
	add $t0, $t5, $t6
    	beq $t0, 49, game_over

	beqz $s7, player_move	  # Player turn
	jal computer_turn
	beqz $s3, update_turn
player_move:
	jal print_board
	jal make_move
	
	# If there was an error, give the player another turn
	beqz $s4, game_loop
	
	# If a box was completed on the previous turn, update the score and give the user another turn
	bge $s3, 1, update_score
	# If a box was not completed on the previous turn
	beqz $s3, update_turn

	j game_loop
    	# Print the current player's name and score
    	#beq $s7, 0, print_player
    	#beq $s7, 1, print_cpu
	
update_score:

	beq $s7, 0, update_user_score # if it's the user turn
	beq $s7, 1, update_cpu_score # if it's the CPU turn
update_user_score:
	add $s5, $s5, $s3 # increment the user score by 1
	j game_loop
update_cpu_score:
	add $s6, $s6, $s3 # increment the CPU score by 1
	j game_loop
	
update_turn:
	addi $s7, $s7, 1
	andi $s7, $s7, 1
	j game_loop

game_over:
    	# Print the final board
    	jal print_board

    	# Print the game over message and the final score
    	li $v0, 4
    	la $a0, game_over_msg
    	syscall
    	    	
    	# Print user score message
    	li $v0, 4
    	la $a0, user_score_msg
    	syscall
    	# Print player score
    	li $v0, 1
    	move $a0, $s5
    	syscall
    	
    	# Print CPU score message
    	li $v0, 4
    	la $a0, cpu_score_msg
    	syscall
    	# Print CPU score
    	li $v0, 1
    	move $a0, $s6
    	syscall
    	
    	# Exit.
    	li $v0, 10
    	syscall
