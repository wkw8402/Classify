.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    li t6, 1
	blt a2, t6, elements
	blt a3, t6, stride
	blt a4, t6, stride #check for malformed input

    li t5, 4 
	mul a3, a3, t5
	mul a4, a4, t5 #both strides are multiplied by 4(size of int) to get strides' address version to facilitate pointer moves

	mv t0, x0 #t0 = doc product 
	mv t1, x0 #t1 = index of current element 

loop_start:
    bge t1, a2, loop_end #loop through the given number of elements

	lw t2, 0(a0) #t2 = value of current element from arr1
	lw t3, 0(a1) #t3 = value of current element from arr2
	mul t4, t2, t3 #t4 = cartesian multiplication of two values
    add t0, t0, t4 #multiplication result added to total doc product 

	add a1, a1, a4 
	add a0, a0, a3 #increment the pointer by the stides' address version
	addi t1, t1, 1 #increment index by 1
    j loop_start

loop_end:
    # Epilogue
    mv a0, t0 #a0 = return the resulting dot product
    jr ra

elements:
	li a0, 36
	j exit

stride:
	li a0, 37
	j exit