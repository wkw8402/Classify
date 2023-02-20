.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
   li t0, 5
   bne a0, t0, incorrect_arguments

   #Prologue
   addi sp, sp, -44
   sw s0, 0(sp)
   sw s1, 4(sp)
   sw s2, 8(sp)
   sw s3, 12(sp)
   sw s4, 16(sp)
   sw s5, 20(sp)
   sw s6, 24(sp)
   sw s7, 28(sp)
   sw s8, 32(sp)
   sw s9, 36(sp)
   sw ra, 40(sp)

   mv s0, a1 #s0 = list of pointers
   mv s1, a2 #s1 = 0 = print out classification, otherwise nothing
  
   # Read pretrained m0
   li a0, 8 #a0 = size of memory to allocate 8 for two pointers each for row and column of m0

   jal malloc
   beq a0, x0, malloc_error

   mv s2, a0 #s2 = pointer to allocated memory for m0's num of rows and num of cols

   mv a1, a0 #a1 = pointer to allocated memory for m0's num of rows
   addi a2, a1, 4 #a2 = pointer to allocated memory for m0's num of cols
   lw a0 4(s0) #a0 = s0[1] = pointer to m0's filepath string

   jal read_matrix

   mv s3, a0 #s3 = pointer to matrix m0

   # Read pretrained m1
   li a0, 8 #a0 = size of memory to allocate 8 for two pointers each for row and column of m1

   jal malloc
   beq a0, x0 malloc_error

   mv s4, a0 #s4 = pointer to allocated memory for m1's num of rows and num of cols

   mv a1, a0 #a1 = pointer to allocated memory for m1's num of rows
   addi a2, a1, 4 #a2 = pointer to allocated memory for m1's num of cols
   lw a0 8(s0) #a0 = s0[2] = pointer to m1's filepath string

   jal read_matrix
   mv s5, a0 #s5 = pointer to matrix m1

   # Read input matrix
   li a0, 8  #a0 = size of memory to allocate 8 for two pointers each for row and column of input matrix

   jal malloc
   beq a0, x0, malloc_error

   mv s6, a0 #s6 = pointer to allocated memory for input matrix's num of rows and num of cols

   mv a1, a0 #a1 = pointer to allocated memory for input matrix's num of rows
   addi a2, a1, 4 #a2 = pointer to allocated memory for input matrix's num of cols
   lw a0 12(s0) #a0 = s0[3] = pointer to input matrix's filepath string

   jal read_matrix
   mv s7, a0 #s7 = pointer to input matrix

   # Compute h = matmul(m0, input)
   lw a1, 0(s2) #a1 = m0's num of rows
   lw a2, 4(s2) #a1 = m0's num of cols
   mv a3, s7 #a3 = pointer to start of input matrix
   lw a4, 0(s6) #a4 = input matrix's num of rows
   lw a5, 4(s6) #a5 = input matrix's num of cols
  
   addi sp, sp -20
   sw a1, 0(sp)
   sw a2, 4(sp)
   sw a3, 8(sp)
   sw a4, 12(sp)
   sw a5, 16(sp)

   mul a0, a1, a5 #a0 = size of matrix h = m0's num of rows * input matrix's num of cols

   slli a0, a0, 2 #multiply size by 4 as we use 4 bytes for each space

   jal malloc
   beq a0, x0 malloc_error

   mv s8, a0 #s8 = pointer to allocated memory of matrix h
   
   lw a5, 16(sp)
   lw a4, 12(sp)
   lw a3, 8(sp)
   lw a2, 4(sp)
   lw a1, 0(sp)
   addi sp, sp 20

   mv a6, a0 #a6 = pointer to allocated memory of matrix h
  
   mv a0, s3 #a0 = pointer to matrix m0

   addi sp, sp, -4
   sw a6, 0(sp) #save the pointer to matrix h before matmul

   jal matmul

   lw a6, 0(sp) #load the pointer to matrix h after matmul
   addi sp, sp 4

   # Compute h = relu(h)
   mv t4, a6 #t4 = pointer to matrix h
  
   lw t1, 0(s2) #t1 = m0's num of rows
   lw t2, 4(s6) #t2 = input matrix's num of cols

   addi sp, sp, -12 #saving temporary registers before calling function relu
   sw t1, 0(sp)
   sw t2, 4(sp)
   sw t4, 8(sp)   

   mv a0, t4 #a0 = pointer to matrix h
   mul a1, t1, t2 #a1 = size of matrix h = m0's num of rows * input matrix's num of cols

   jal relu
  
   lw t4 8(sp)
   lw t2 4(sp)
   lw t1 0(sp)
   addi sp, sp, 12

   # Compute o = matmul(m1, h)
   lw a1, 0(s4) #a1 = m1's num of rows
   lw a2, 4(s4) #a2 = m2's num of cols
   mv a3, t4 #a3 = pointer to matrix h
   mv a4, t1 #a4 = h's num of rows = m0's num of rows
   mv a5, t2 #a5 = h's num of cols = input matrix's num of cols

   mul t3, a1, a5 #t3 = size of matrix o = m1's num of rows * h's num of cols
  
   addi sp, sp, -24
   sw a1, 0(sp)
   sw a2, 4(sp)
   sw a3, 8(sp)
   sw a4, 12(sp)
   sw a5, 16(sp)
   sw t3, 20(sp)

   slli a0, t3, 2 #multiply size by 4 as we use 4 bytes for each space

   jal malloc
   beq a0, x0, malloc_error

   lw t3, 20(sp)
   lw a5, 16(sp)
   lw a4, 12(sp)
   lw a3, 8(sp)
   lw a2, 4(sp)
   lw a1, 0(sp)
   addi sp, sp, 24

   mv a6, a0 #a6 = pointer to matrix o
   mv a0, s5 #a0 = pointer to matrix m1

   addi sp, sp, -16
   sw a1, 0(sp)
   sw a5, 4(sp)
   sw a6, 8(sp) #save the pointer to matrix o before matmul
   sw t3, 12(sp)

   jal matmul 

   lw t3, 12(sp)
   lw a6, 8(sp) #load the pointer to matrix o after matmul
   lw a5, 4(sp)
   lw a1, 0(sp)
   addi sp, sp, 16

   # Write output matrix o
   lw a0, 16(s0) #a0 = s0[4] = pointer to output file's filepath string
   mv a2, a1 #a2 = m1's num of rows
   mv a1, a6 #a1 = pointer to matrix o
   mv a3, a5 #a3 = h's num of cols

   addi sp, sp, -8
   sw a1, 0(sp) 
   sw t3, 4(sp) #saving temporary register that contains the size of matrix o before calling function write_matrix

   jal write_matrix

   lw t3, 4(sp)
   lw a1, 0(sp)
   addi sp, sp, 8

   #Compute and return argmax(o)
   mv a0, a1 #a0 = pointer to matrix o
   mv a1, t3 #a1 = size of matrix o

   jal argmax
   mv s9, a0 #s9 = index of largest element in matrix o

   # If enabled, print argmax(o) and newline
   beq s1, x0, print_out #if s1 = 0 = print out classification, otherwise nothing
   j afterwards

print_out:
   jal print_int #print out the index of largest element in matrix o, a0 is still equal to index of largest element in matrix o

   li a0 '\n'
   jal print_char #print out new line character

afterwards:
   mv a0 s3 #free pointer to m0
   jal free
   mv a0 s7 #free pointer to input matrix
   jal free
   mv a0 s5 #free pointer to m1
   jal free
   mv a0 s8 #free pointer to matrix h
   jal free

   mv a0 s2 #free pointer to allocated memory for m0's num of rows and num of cols
   jal free
   mv a0 s4 #free pointer to allocated memory for m1's num of rows and num of cols
   jal free
   mv a0 s6 #free pointer to allocated memory for input matrix's num of rows and num of cols
   jal free

   mv a0 s9 # a0 = final return value, argmax(o)

   #Epilogue
   lw s0, 0(sp)
   lw s1, 4(sp)
   lw s2, 8(sp)
   lw s3, 12(sp)
   lw s4, 16(sp)
   lw s5, 20(sp)
   lw s6, 24(sp)
   lw s7, 28(sp)
   lw s8, 32(sp)
   lw s9, 36(sp)
   lw ra, 40(sp)
   addi sp, sp, 44

   jr ra

incorrect_arguments:
   li a0, 31
   jal exit

malloc_error:
   li a0, 26
   jal exit