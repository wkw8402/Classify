.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    li t0, 1
    blt a1, t0, malformed #if the length of the array is less than 1
    mv t1, zero

loop_start:
    bge t1, a1, loop_end #t1 is the index of the current element 

    addi t2, x0, 4 #size of integer = 4 bytes
    mul t3, t1, t2 #calculating the address of current element
    add t4, t3, a0

    lw t5, 0(t4) #t5 = value of current element

    bgt t5, x0, loop_continue #if the value is positive or 0, nothing to do

    mv t5, x0 #otherwise, make negative value to zero
    sw t5, 0(t4) #store 0 back in its place

loop_continue:
    addi t1, t1, 1 #increment the index
    j loop_start

loop_end:
    # Epilogue
    jr ra

malformed:
    li a0, 36
    j exit