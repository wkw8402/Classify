.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    bne a2, a4, malformed #m0's row does not match with m1's column
    ble a1, zero, malformed
    ble a2, zero, malformed
    ble a4, x0, malformed
    ble a5, x0, malformed #less than 1 = less than or equal to 0

    # Prologue
	addi sp, sp, -12 #stack pointers
    sw s0, 0(sp)
    sw s1, 4(sp)
	sw ra, 8(sp) #saving saved registers and return address on stack memory

    li s0, 0 #row index of m0

outer_loop_start:
    li s1, 0 #col index of m1

inner_loop_start:
    addi sp, sp, -32 #stack pointers
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw ra, 28(sp) #saving arguments and return address on stack memory temporarily

	li t2, 4 
    mul t1, s1, t2 
    add a1, a3, t1 #a1 to be on different column for every iteration of inner_loop
    li a3, 1
    mv a4, a5

    jal dot #a0 = arr0 start pointer, a1 = arr1 start pointer, a2 = #elements, a3 = stride of arr0 = 1, a4 = stride of arr1 = # of columns or width of m1
    mv t5, a0 #t5 = dot product

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32 #restoring arguments and return address from stack pointer to get original argument of matmul

    mul t0, s0, a5 #d's shape is (m0's row x m1's col)
    add t0, t0, s1 #t0 = computed the row-col position of current dot product on matrix d (row-major) by multiplying row index by m1's width and then adding col index
    

    li t2, 4
    mul t1, t0, t2 #t1 = address of current row-col position on d to store
    add t1, t1, a6 
    sw t5, 0(t1) #add current dot product on the corresponding row-col of d

inner_loop_end:
    addi s1, s1, 1 #increment the m1's col index by 1
    blt s1, a5, inner_loop_start #loop through every column of m1

outer_loop_end:
    # Epilogue
    addi s0, s0, 1 #increment the m0's row index by 1

    li t6, 4
    mul t3, a2, t6
    add a0, a0, t3 #update the pointer to m0 by moving on to next row by skipping the m0's width(a2)

    blt s0, a1, outer_loop_start #loop through every row of m0

	lw s0, 0(sp)
    lw s1, 4(sp)
	lw ra, 8(sp)
    addi sp, sp, 12 #restoring saved registers and return address back from stack pointer

    jr ra

malformed:
	li a0, 38
	j exit