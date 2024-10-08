.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
	li t0, 1
	blt a1, t0, malformed

	mv t5, x0 #index of the largest element
    mv t2, zero		

	lw t6, 0(a0) #t6 = maximum value, initially at value of first element

loop_start:
	beq t2, a1, loop_end #loop through the array

	lw t3, 0(a0) 	 	

	ble t3, t6, loop_continue #check the current element with maximum 
	mv t6, t3  #if current > max, t6 = current element = new maximum			
	mv t5, t2	#index of maximum  = t5 set to index of current element		

loop_continue:
	li t4, 4 #if current is less than or equal to maximum, 
	add a0, a0, t4 #move on to next address

	addi t2, t2, 1 #increment the index by 1
	j loop_start

loop_end:
	# Epilogue
	mv a0, t5 #output set to index of maximum
    jr ra

malformed:
	li a0, 36
	j exit