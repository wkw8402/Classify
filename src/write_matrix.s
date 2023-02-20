.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    #Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)

    mv s0, a1 #s0 = pointer to matrix in memory
    mv s1, a2 #s1 = num of rows
    mv s2, a3 #s2 = num of cols
    mul s3, s1, s2 #s3 = size of elements = rows * cols

	li a1, 1 #a1 = permission bit set to 1 for write-only
    jal fopen #a0 = pointer to filename string

    blt a0 x0 fopen_error #if opening the file failed, a0 = -1

    mv s4, a0 #s4 = file descriptor

    addi sp, sp, -4
    sw s1, 0(sp) #save s1 = num of rows into memory so that sp becomes pointer to data in memory

	mv a0, s4 #a0 = file descriptor
    mv a1, sp #a1 = pointer to a buffer(num of rows) containing what we want to write to file
	li a2, 1 #a2 = num of element = 1
	li a3, 4 #a3 = size of each element = 4 bytes

    jal fwrite
	
    blt a0, x0, fwrite_error #a0 = return value = number of items written to the file

    sw s2, 0(sp) #save s2 = num of cols into memory so that sp becomes pointer to data in memory
    
    mv a0, s4 #a0 = file descriptor
    mv a1, sp #a1 = pointer to a buffer(num of cols) containing what we want to write to file
	li a2, 1 #a2 = num of element = 1
	li a3, 4 #a3 = size of each element = 4 bytes

    jal fwrite

    blt a0, x0, fwrite_error #a0 = return value = number of items written to the file

    addi sp, sp, 4

writing_matrix:

    mv a0, s4 #a0 = file descriptor
    mv a1, s0 #a1 = pointer to matrix, buffer containing what we want to write to file
    mv a2, s3 #a2 = number of elements to write = rows * cols
	li a3, 4 #a3 = size of each element = 4 bytes
	
    jal fwrite

    blt a0, x0, fwrite_error #a0 = return value = number of items written to the file

    bne a0, s3, writing_matrix #loop until we write every needed bytes

    mv a0, s4 #a0 = file descriptor
    jal fclose

    bne a0, x0, fclose_error

    #Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24
	
    jr ra

fopen_error:
    li a0, 27
    j exit

fwrite_error:
    li a0, 30
    j exit

fclose_error:
    li a0, 28
    j exit

