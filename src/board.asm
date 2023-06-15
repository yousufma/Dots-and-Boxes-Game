
.data
boxes: 			.space 64 #i don't need the full "2d" array for each of these, but making same dimensions makes access easy
horizontal_lines: 	.space 64 
vertical_lines: 	.space 64 
column_label: 		.asciiz	"     0   1   2   3   4   5   6"
horizontal_bar: 	.asciiz	"---"
horizontal_space: 	.asciiz	"   "
short_space: 		.asciiz	"  "
.space 2
main_return: 		.word
move_cpu_return: 	.word
validation_return: 	.word


.text
#.globl print_board
#.globl check_if_placed


#t0 = line indicator, t1 = char indicator t2= temporary for math $t3= array inndex $t4= array contents $t7 = 7

print_board:
        la $t5, horizontal_lines #load address of horizontal lines array
        la $t6, vertical_lines #load address of vertical lines array
    	li $t7, 7 #load 7 for calculating box matrix
    	la $t8, boxes #initialiaze t8 to the address of boxes array for later
	li $t0, 0 #line indicator
	li $v0, 4 
        la $a0, column_label
        syscall #print column labels
        
        li $v0, 11
        addi $a0, $0, 0xA       #newline
	syscall
	

print_loop:
	li $t1, 0 # character indicator reset every time a line finished
	beq $t0, 15, return #return if table is fully printed
	andi $t3, $t0, 1 #check if line indicator odd or even
	beq  $t3, 1, vertical_start 	#jump to vertical if odd
	
horizontal_start:
	li $v0, 4
    	la $a0, horizontal_space #print some spaces
    	syscall

horizontal:
	beq  $t1, 7, last_horizontal # if this is the last horizontal character, break to last to only print '+'

    	
	li $v0, 11
        li $a0, '+' #print '+'
        syscall	
        
        # print bar or space
        sll $t2, $t0, 2 #multiply row counter by 4(it is already 2 times correct index) to get 8x for pseudo 2d matrix
        add $t3, $t1, $t2 # add char counter 
        
        add $t3, $t3, $t5
	lbu $t4, ($t3)	#load contents of array address
	beqz $t4, print_space_horizontal 	# of empty, go print a space
	j print_bar_horizontal	#else print a bar
	
horizontal_return:
	
	addi $t1, $t1, 1
	j horizontal
vertical_start:
	addi $t4, $t0, 1
	srl $t4, $t4, 1
	addi $a0, $t4, -1
	li $v0, 1 #print label number
	syscall
	
	li $v0, 4
    	la $a0, short_space
    	syscall
vertical:    	
	beq  $t1, 7, last_vertical

    	# print bar or space
    	addi $t2, $t0, -1
    	sll $t2, $t2, 2 #same deal as before, but have to subtract 1 first as well
    	add $t3, $t1, $t2 
        add $t3, $t3, $t6
        
	lbu $t4, ($t3)	#load the array data
    	beqz $t4, print_space_vertical	#if empty, print a space
	j print_bar_vertical # otherwise print a bar
    	
vertical_return:    	
    	
    	li $v0, 11
    	li $a0, ' '
    	syscall
    	
    	# print box owner
    	srl $t3, $t0, 1
    	addi $t3, $t3, 1
    	mult $t3, $t7
    	mflo $t3
    	add $t3, $t3, $t0
        add $t3, $t3, $t8
	lbu $t4, ($t3)
    	beqz $t4, no_owner
	li $v0, 1 
	syscall
	j owner
	
no_owner:
	li $v0, 11
    	li $a0, ' '
    	syscall
	j no_owner_skip
owner:   	
	li $v0, 11
	lbu $a0, ($t3)
    	syscall
    	
no_owner_skip:   	
    	li $v0, 11
    	li $a0, ' '
    	syscall
    	
	
	addi $t1, $t1, 1
	j vertical
	
	
	#these are all just functions to be called by the horizontal and vertical loops above
print_space_horizontal:
	li $v0, 4
    	la $a0, horizontal_space
    	syscall
    	j horizontal_return
print_bar_horizontal:
	li $v0, 4
    	la $a0, horizontal_bar
    	syscall
    	j horizontal_return

print_space_vertical:
	li $v0, 11
    	li $a0, ' '
    	syscall
    	j vertical_return
print_bar_vertical:
	li $v0, 11
    	li $a0, 0x7c
    	syscall
    	j vertical_return
    	
    	
last_horizontal:
	addi $t0, $t0, 1	
	li $v0, 11
        li $a0, '+'
        syscall	
        
        li $v0, 11
        addi $a0, $0, 0xA       
	syscall
	
	j print_loop
last_vertical:
	addi $t0, $t0, 1
	
	addi $t2, $t0, -2
    	sll $t2, $t2, 2
    	add $t3, $t1, $t2
        add $t3, $t3, $t6
	lbu $t4, ($t3)
    	beqz $t4, print_space_vertical_end
	li $v0, 11
    	li $a0, '|'
    	syscall
    	
	j vertical_end
	
print_space_vertical_end:
	li $v0, 11
    	li $a0, ' '
    	syscall
    	
vertical_end:	
	li $v0, 11
        addi $a0, $0, 0xA       
	syscall
	j print_loop


#t0= math t1= address t2= data(later address to store box) t3= vertical offset t4= horizontal offset $t7=other lines to check t8= box array t9= char to place
check_if_placed:

	la $t5, horizontal_lines #load address of horizontal lines array
        la $t6, vertical_lines
        la $t8, boxes
        
        beqz $s7, user_turn
        
        
cpu_turn:
	li $t9, 'C'
	j check_continue

user_turn:
	li $t9, 'U'

check_continue:
	#find address of horizontal or vertical bar and if it exists, return with v1=1, v0=0
	andi $t0, $s2, 1
	beqz $t0, place_horizontal
	
place_vertical: 
	#calc vertical address
	sll $t3, $s0, 3 #multiply row by 8 
	
	beq $s2, 3, plus_one_vertical #if it is a three, we dont need to add 1 to the horizontal offset
	addi  $t4, $zero, 1 #add 1 offset if direction is right
plus_one_vertical:
	add $t4, $t4, $s1 #add horizontal component
	add $t1, $t3, $t4
	add $t1, $t1, $t6
	lbu $t2, ($t1)
	beqz $t2, save_vertical
	j invalid

#if it does not exist, place '|'
save_vertical:
	li $t0, '|'
	li $s4, 1
	sb $t0, ($t1)
	
	add $t2, $t8, $t3 #calc box address
	add $t2, $t2, $t4

	la $t0, horizontal_lines #this is here for checking if boxes completed for the other line orientation
	add $t0, $t0, $t3
	add $t0, $t0, $t4
	
	lbu $t7, -1($t1)
	bne $t7, '|', next_vertical_check
	
	lbu $t7, -1($t0)
	bne $t7, '-', next_vertical_check
	
	lbu $t7, 7($t0)
	bne $t7, '-', next_vertical_check
	addi $s3, $zero, 1
	
	
	sb $t9, -1($t2) #place box owner

next_vertical_check:
	lbu $t7, 1($t1)
	bne $t7, '|', return
	
	lbu $t7, ($t0)
	bne $t7, '-', return
	
	lbu $t7, 8($t0)
	bne $t7, '-', return
	addi $s3, $s3, 1
	
	sb $t9, ($t2) #place box owner
	
	
	j return

place_horizontal:
	#calc horizontal address
	srl $t0, $s2, 1
	add $t4, $t0, $s0
	sll $t4, $t4, 3
	add $t3, $zero, $s1
	add $t1, $t3, $t4
	add $t1, $t1, $t5
	lbu $t2, ($t1)
	beqz $t2, save_horizontal
	j invalid

#if it does not exist, place '-' 
save_horizontal:
	li $t0, '-'
	li $s4, 1
	sb $t0, ($t1)
	
	add $t2, $t8, $t3 #calc box address
	add $t2, $t2, $t4

	
	la $t0, vertical_lines #this is here for checking if boxes completed for the other line orientation
	add $t0, $t0, $t3
	add $t0, $t0, $t4
	
	lbu $t7, -8($t1)
	bne $t7, '-', next_horizontal_check
	
	lbu $t7, -8($t0)
	bne $t7, '|', next_horizontal_check
	
	lbu $t7, -7($t0)
	bne $t7, '|', next_horizontal_check
	addi $s3, $zero, 1
	
	sb $t9, -8($t2) #place box owner

next_horizontal_check:
	lbu $t7, 8($t1)
	bne $t7, '-', return
	
	lbu $t7, ($t0)
	bne $t7, '|', return
	
	lbu $t7, 1($t0)
	bne $t7, '|', return
	addi $s3, $s3, 1
	
	sb $t9, ($t2) #place box owner
	
	j return
invalid:
	addi $s4, $zero, 0
	addi $s3, $zero, 0
	j return
	

return: jr $ra
