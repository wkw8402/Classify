.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
	#Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)

    mv s0, a1 #s0 = pointer to num of rows
    mv s1, a2 #s1 = pointer to num of cols
	
	mv a1, x0 #setting permission bit to 0 for read-only
    jal fopen #a0 = pointer to filename string, a1 = permission bit

	blt a0, x0, fopen_error #if opening the file failed, return value a0 is -1

    mv s3, a0 #s3 = file descriptor
 
	mv a1, s0 #a1 = pointer to buffer for num of rows
    li a2, 4
    jal fread #a0 = file descriptor, a2 = num of bytes to read = 4

    blt a0, x0, fread_error 
	
    mv a0, s3 #a0 is now back to file descriptor
    mv a1, s1 #a1 = pointer to buffer for num of cols
    li a2, 4
    jal fread #a0 = file descriptor, a2 = num of bytes to read = 4
    
    blt a0, x0, fread_error

    lw t0, 0(s0) #loading num of rows to t0
    lw t1, 0(s1) #loading num of cols to t1

    mul t2, t0, t1 #t2 = space to allocate = rows * cols

    slli t2, t2, 2 #multiply by 4 as we use 4 bytes for each space

    mv s5, t2 #s5 = size of memory to allocate
    mv a0, s5
    jal malloc #a0 = size of memory to allocate
	
    beq a0, x0, malloc_error #if allocation failed, return value a0 = 0

	mv s2, a0 #s2 = pointer to allocated memory
    mv s4, a0 #s4 = pointer to allocated memory

reading_matrix:
	mv a0, s3 #a0 = file descriptor
    mv a1, s2 #a1 = pointer to allocated memory
    mv a2, s5 #a2 = size of memory to allocate

    jal fread #return a0 = number of bytes read
    add s2, a0, s2 #s2 = number of bytes that we have read from memory so far

    blt s2, s5, reading_matrix #loop until we read every needed bytes or s1

    mv a0 s3 #a0 = file descriptor
    jal fclose

    bne a0, x0, fclose_error #a0 = 0 on success, and -1 on failure
    
    mv a0 s4 #a0 = pointer to allocated memory

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28

    jr ra

fopen_error:
    li a0, 27
    j exit

fread_error:
    li a0, 29
    j exit

malloc_error:
    li a0, 26
    j exit

fclose_error:
    li a0, 28
    j exit


