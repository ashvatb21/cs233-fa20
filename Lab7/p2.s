# #define MAX_GRIDSIZE 16
# #define MAX_MAXDOTS 15

# /*** begin of the solution to the puzzle ***/

# // encode each domino as an int
# int encode_domino(unsigned char dots1, unsigned char dots2, int max_dots) {
#     return dots1 < dots2 ? dots1 * max_dots + dots2 + 1 : dots2 * max_dots + dots1 + 1;
# }
.globl encode_domino
encode_domino:

if:

        bge $a0, $a1, else      # dots1 < dots2 ?
        mul $t0, $a0, $a2       # dots1 * max_dots
        add $t1, $a1, 1         # dots2 + 1
        add $v0, $t0, $t1       # return dots1 * max_dots + dots2 + 1

        j end

else:

        mul $t0, $a1, $a2       # dots2 * max_dots
        add $t1, $a0, 1         # dots1 + 1
        add $v0, $t0, $t1       # return dots2 * max_dots + dots1 + 1

        j end

end:

        jr      $ra

# // main solve function, recurse using backtrack
# // puzzle is the puzzle question struct
# // solution is an array that the function will fill the answer in
# // row, col are the current location
# // dominos_used is a helper array of booleans (represented by a char)
# //   that shows which dominos have been used at this stage of the search
# //   use encode_domino() for indexing
# int solve(dominosa_question* puzzle, 
#           unsigned char* solution,
#           int row,
#           int col) {
#
#     int num_rows = puzzle->num_rows;
#     int num_cols = puzzle->num_cols;
#     int max_dots = puzzle->max_dots;
#     int next_row = ((col == num_cols - 1) ? row + 1 : row);
#     int next_col = (col + 1) % num_cols;
#     unsigned char* dominos_used = puzzle->dominos_used;
#
#     if (row >= num_rows || col >= num_cols) { return 1; }
#     if (solution[row * num_cols + col] != 0) { 
#         return solve(puzzle, solution, next_row, next_col); 
#     }
#
#     unsigned char curr_dots = puzzle->board[row * num_cols + col];
#
#     if (row < num_rows - 1 && solution[(row + 1) * num_cols + col] == 0) {
#         int domino_code = encode_domino(curr_dots,
#                                         puzzle->board[(row + 1) * num_cols + col],
#                                         max_dots);
#
#         if (dominos_used[domino_code] == 0) {
#             dominos_used[domino_code] = 1;
#             solution[row * num_cols + col] = domino_code;
#             solution[(row + 1) * num_cols + col] = domino_code;
#             if (solve(puzzle, solution, next_row, next_col)) {
#                 return 1;
#             }
#             dominos_used[domino_code] = 0;
#             solution[row * num_cols + col] = 0;
#             solution[(row + 1) * num_cols + col] = 0;
#         }
#     }
#     if (col < num_cols - 1 && solution[row * num_cols + (col + 1)] == 0) {
#         int domino_code = encode_domino(curr_dots,
#                                         puzzle->board[row * num_cols + (col + 1)],
#                                         max_dots);
#         if (dominos_used[domino_code] == 0) {
#             dominos_used[domino_code] = 1;
#             solution[row * num_cols + col] = domino_code;
#             solution[row * num_cols + (col + 1)] = domino_code;
#             if (solve(puzzle, solution, next_row, next_col)) {
#                 return 1;
#             }
#             dominos_used[domino_code] = 0;
#             solution[row * num_cols + col] = 0;
#             solution[row * num_cols + (col + 1)] = 0;
#         }
#     }
#     return 0;
# }
.globl solve
solve:
        # Plan out your registers and their lifetimes ahead of time. You will almost certainly run out of registers if you
        # do not plan how you will use them. If you find yourself reusing too much code, consider using the stack to store
        # some variables like &solution[row * num_cols + col] (caller-saved convention).


        # STACK VARIABLES (ALWAYS TO BE SAVED)
        lw $t0, 0($a0)                  # int num_rows = puzzle->num_rows
        lw $t1, 4($a0)                  # int num_cols = puzzle->num_cols
        lw $t2, 8($a0)                  # int max_dots = puzzle->max_dots
        li $t3, 0                       # int next_row
        li $t4, 0                       # int next_col
        li $t5, 0                       # unsigned char* dominos_used[]
        li $t6, 0                       # unsigned char curr_dots
        li $t7, 0                       # solution[row * num_cols + col]
        li $t8, 0                       # solution[(row + 1) * num_cols + col] 
        li $t9, 0                       # solution[row * num_cols + (col + 1)]
        li $s3, 0                       # solution[row * num_cols + col] offset
        li $s4, 0                       # solution[(row + 1) * num_cols + col] offset
        li $s5, 0                       # solution[row * num_cols + (col + 1)] offset
        li $s6, 0                       # domino_code


        sub $s0, $t1, 1                 # num_cols - 1
        add $s1, $a2, 1                 # row + 1
        add $s2, $a3, 1                 # col + 1
        
if_assign:                          

        bne $a3, $s0, else_assign       # !(col == num_cols - 1)
        move $t3, $s1                   # int next_row = row + 1

        j end_if_assign

else_assign:

        move $t3, $a2                   # int next_row = row

end_if_assign:

        rem $t4, $s2, $t1               # int next_col = (col + 1) % num_cols
        lw $t5, 268($a0)                # unsigned char* dominos_used = puzzle->dominos_used


        bge $a2, $t0, if1               # if (row >= num_rows) ||
        blt $a3, $t1, end_if1           # if !(col >= num_cols)

if1:    

        li $v0, 1                     # return 1
        jr $ra

end_if1:

        # $t7 - $t9 defines
        mul $s3, $a2, $t1               # row * num_cols
        add $s3, $s3, $a3               # [row * num_cols + col]
        add $s3, $s3, $a1               # solution[row * num_cols + col] offset
        lb $t7, 0($s3)                  # solution[row * num_cols + col]
        
        add $s4, $a2, 1                 # row + 1
        mul $s4, $s4, $t1               # (row + 1) * num_cols
        add $s4, $s4, $a3               # [(row + 1) * num_cols + col]
        add $s4, $s4, $a1               # solution[(row + 1) * num_cols + col] offset
        lb $t8, 0($s4)                  # solution[(row + 1) * num_cols + col]

        mul $s5, $a2, $t1               # row * num_cols
        add $s5, $s5, $a3               # [row * num_cols + col]
        add $s5, $s5, 1                 # [row * num_cols + (col + 1)]
        add $s5, $s5, $a1               # solution[row * num_cols + (col + 1)] offset
        lb $t9, 0($s5)                  # solution[row * num_cols + (col + 1)]

if2:

        beq $t7, 0, end_if2             # if !(solution[row * num_cols + col] != 0) 

        sub $sp, $sp, 76
        sw $ra, 0($sp)
        sw $a0, 4($sp)
        sw $a1, 8($sp)
        sw $a2, 12($sp)
        sw $a3, 16($sp)
        sw $t0, 20($sp)
        sw $t1, 24($sp)
        sw $t2, 28($sp)
        sw $t3, 32($sp)
        sw $t4, 36($sp)
        sw $t5, 40($sp)
        sw $t6, 44($sp)
        sw $t7, 48($sp)
        sw $t8, 52($sp)
        sw $t9, 56($sp)
        sw $s3, 60($sp)
        sw $s4, 64($sp)
        sw $s5, 68($sp)
        sw $s6, 72($sp)

        move $a2, $t3                   # next_row
        move $a3, $t4                   # next_col

        jal solve                       # solve(puzzle, solution, next_row, next_col)

        lw $ra, 0($sp)
        lw $a0, 4($sp)
        lw $a1, 8($sp)
        lw $a2, 12($sp)
        lw $a3, 16($sp)
        lw $t0, 20($sp)
        lw $t1, 24($sp)
        lw $t2, 28($sp)
        lw $t3, 32($sp)
        lw $t4, 36($sp)
        lw $t5, 40($sp)
        lw $t6, 44($sp)
        lw $t7, 48($sp)
        lw $t8, 52($sp)
        lw $t9, 56($sp)
        lw $s3, 60($sp)
        lw $s4, 64($sp)
        lw $s5, 68($sp)
        lw $s6, 72($sp)
        add $sp, $sp, 76

        jr $ra 

end_if2:

        # $t6 define
        mul $s0, $a2, $t1               # row * num_cols
        add $s0, $s0, $a3               # [row * num_cols + col]
        la $s1, 12($a0)                 # Address of puzzle->board[0]
        add $s1, $s1, $s0               # Offset for board[row * num_cols + col]
        lb $t6, 0($s1)                  # unsigned char curr_dots = puzzle->board[row * num_cols + col]

if_outer1:

        sub $s0, $t0, 1                 # num_rows - 1

        bge $a2, $s0, if_outer2          # if !(row < num_rows - 1) &&
        bne $t8, 0, if_outer2            # if !( solution[(row + 1) * num_cols + col] == 0)

        sub $sp, $sp, 76
        sw $ra, 0($sp)
        sw $a0, 4($sp)
        sw $a1, 8($sp)
        sw $a2, 12($sp)
        sw $a3, 16($sp)
        sw $t0, 20($sp)
        sw $t1, 24($sp)
        sw $t2, 28($sp)
        sw $t3, 32($sp)
        sw $t4, 36($sp)
        sw $t5, 40($sp)
        sw $t6, 44($sp)
        sw $t7, 48($sp)
        sw $t8, 52($sp)
        sw $t9, 56($sp)
        sw $s3, 60($sp)
        sw $s4, 64($sp)
        sw $s5, 68($sp)
        sw $s6, 72($sp)

        add $s0, $a2, 1                 # row + 1
        mul $s0, $s0, $t1               # (row + 1) * num_cols
        add $s0, $s0, $a3               # [(row + 1) * num_cols + col]
        la $s1, 12($a0)                 # Address of puzzle->board[0]
        add $s1, $s1, $s0               # Offset for board[(row + 1) * num_cols + col]
        lb $s2, 0($s1)                  # puzzle->board[(row + 1) * num_cols + col]

        move $a0, $t6                   # curr_dots
        move $a1, $s2                   # puzzle->board[(row + 1) * num_cols + col]
        move $a2, $t2                   # max_dots

        jal encode_domino

        lw $ra, 0($sp)
        lw $a0, 4($sp)
        lw $a1, 8($sp)
        lw $a2, 12($sp)
        lw $a3, 16($sp)
        lw $t0, 20($sp)
        lw $t1, 24($sp)
        lw $t2, 28($sp)
        lw $t3, 32($sp)
        lw $t4, 36($sp)
        lw $t5, 40($sp)
        lw $t6, 44($sp)
        lw $t7, 48($sp)
        lw $t8, 52($sp)
        lw $t9, 56($sp)
        lw $s3, 60($sp)
        lw $s4, 64($sp)
        lw $s5, 68($sp)
        lw $s6, 72($sp)
        add $sp, $sp, 76

        move $s6, $v0                   # int domino_code 

if_inner1:

        add $s0, $t5, $s6               # dominos_used[domino_code] offset
        lb $s1, 0($s0)                  # dominos_used[domino_code]

        bne $s1, 0, end_if_inner1       # if !(dominos_used[domino_code] == 0)

        li $s1, 1                       # dominos_used[domino_code] = 1
        lb $s1, 0($s0)                  # storing value back into memory

        move $t7, $s6                   # solution[row * num_cols + col] = domino_code
        sb $t7, 0($s3)                  # storing solution[row * num_cols + col]
        
        move $t8, $s6                   # solution[(row + 1) * num_cols + col] = domino_code
        sb $t8, 0($s4)                  # storing solution[(row + 1) * num_cols + col]


if_inner2:

        sub $sp, $sp, 76
        sw $ra, 0($sp)
        sw $a0, 4($sp)
        sw $a1, 8($sp)
        sw $a2, 12($sp)
        sw $a3, 16($sp)
        sw $t0, 20($sp)
        sw $t1, 24($sp)
        sw $t2, 28($sp)
        sw $t3, 32($sp)
        sw $t4, 36($sp)
        sw $t5, 40($sp)
        sw $t6, 44($sp)
        sw $t7, 48($sp)
        sw $t8, 52($sp)
        sw $t9, 56($sp)
        sw $s3, 60($sp)
        sw $s4, 64($sp)
        sw $s5, 68($sp)
        sw $s6, 72($sp)        

        move $a2, $t3                   # next_row
        move $a3, $t4                   # next_col

        jal solve

        lw $ra, 0($sp)
        lw $a0, 4($sp)
        lw $a1, 8($sp)
        lw $a2, 12($sp)
        lw $a3, 16($sp)
        lw $t0, 20($sp)
        lw $t1, 24($sp)
        lw $t2, 28($sp)
        lw $t3, 32($sp)
        lw $t4, 36($sp)
        lw $t5, 40($sp)
        lw $t6, 44($sp)
        lw $t7, 48($sp)
        lw $t8, 52($sp)
        lw $t9, 56($sp)
        lw $s3, 60($sp)
        lw $s4, 64($sp)
        lw $s5, 68($sp)
        lw $s6, 72($sp)
        add $sp, $sp, 76

        bne $v0, 1, end_if_inner2       # if !(solve(puzzle, solution, next_row, next_col))
        li $v0, 1                     # return 1
        jr $ra

end_if_inner2:

        add $s0, $t5, $s6               # dominos_used[domino_code] offset
        lb $s1, 0($s0)                  # dominos_used[domino_code]
        li $s1, 0                       # dominos_used[domino_code] = 0
        lb $s1, 0($s0)                  # storing value back into memory

        move $t7, $zero                 # solution[row * num_cols + col] = 0
        sb $t7, 0($s3)                  # storing solution[row * num_cols + col]
        
        move $t8, $zero                 # solution[(row + 1) * num_cols + col] = 0
        sb $t8, 0($s4)                  # storing solution[(row + 1) * num_cols + col]



# SECOND IF SECTION


if_outer2:

        sub $s0, $t1, 1                 # num_col - 1

        bge $a3, $s0, end_code               # if !(col < num_col - 1) &&
        bne $t9, 0, end_code                 # if !( solution[row * num_cols + (col + 1)] == 0)

        sub $sp, $sp, 76
        sw $ra, 0($sp)
        sw $a0, 4($sp)
        sw $a1, 8($sp)
        sw $a2, 12($sp)
        sw $a3, 16($sp)
        sw $t0, 20($sp)
        sw $t1, 24($sp)
        sw $t2, 28($sp)
        sw $t3, 32($sp)
        sw $t4, 36($sp)
        sw $t5, 40($sp)
        sw $t6, 44($sp)
        sw $t7, 48($sp)
        sw $t8, 52($sp)
        sw $t9, 56($sp)
        sw $s3, 60($sp)
        sw $s4, 64($sp)
        sw $s5, 68($sp)
        sw $s6, 72($sp)

        mul $s0, $a2, $t1               # row * num_cols
        add $s0, $s0, $a3               # [row * num_cols + col]
        add $s0, $s0, 1                 # [row * num_cols + (col + 1)]
        la $s1, 12($a0)                 # Address of puzzle->board[0]
        add $s1, $s1, $s0               # Offset for board[row * num_cols + (col + 1)]
        lb $s2, 0($s1)                  # puzzle->board[row * num_cols + (col + 1)]

        move $a0, $t6                   # curr_dots
        move $a1, $s2                   # puzzle->board[row * num_cols + (col + 1)]
        move $a2, $t2                   # max_dots

        jal encode_domino

        lw $ra, 0($sp)
        lw $a0, 4($sp)
        lw $a1, 8($sp)
        lw $a2, 12($sp)
        lw $a3, 16($sp)
        lw $t0, 20($sp)
        lw $t1, 24($sp)
        lw $t2, 28($sp)
        lw $t3, 32($sp)
        lw $t4, 36($sp)
        lw $t5, 40($sp)
        lw $t6, 44($sp)
        lw $t7, 48($sp)
        lw $t8, 52($sp)
        lw $t9, 56($sp)
        lw $s3, 60($sp)
        lw $s4, 64($sp)
        lw $s5, 68($sp)
        lw $s6, 72($sp)
        add $sp, $sp, 76

        move $s6, $v0                   # int domino_code 

if_inner3:

        add $s0, $t5, $s6               # dominos_used[domino_code] offset
        lb $s1, 0($s0)                  # dominos_used[domino_code]

        bne $s1, 0, end_if_inner3       # if !(dominos_used[domino_code] == 0)

        li $s1, 1                       # dominos_used[domino_code] = 1
        lb $s1, 0($s0)                  # storing value back into memory

        move $t7, $s6                   # solution[row * num_cols + col] = domino_code
        sb $t7, 0($s3)                  # storing solution[row * num_cols + col]
        
        move $t9, $s6                   # solution[(row + 1) * num_cols + col] = domino_code
        sb $t9, 0($s5)                  # storing solution[row * num_cols + (col + 1)]


if_inner4:

        sub $sp, $sp, 76
        sw $ra, 0($sp)
        sw $a0, 4($sp)
        sw $a1, 8($sp)
        sw $a2, 12($sp)
        sw $a3, 16($sp)
        sw $t0, 20($sp)
        sw $t1, 24($sp)
        sw $t2, 28($sp)
        sw $t3, 32($sp)
        sw $t4, 36($sp)
        sw $t5, 40($sp)
        sw $t6, 44($sp)
        sw $t7, 48($sp)
        sw $t8, 52($sp)
        sw $t9, 56($sp)
        sw $s3, 60($sp)
        sw $s4, 64($sp)
        sw $s5, 68($sp)
        sw $s6, 72($sp)        

        move $a2, $t3                   # next_row
        move $a3, $t4                   # next_col

        jal solve

        lw $ra, 0($sp)
        lw $a0, 4($sp)
        lw $a1, 8($sp)
        lw $a2, 12($sp)
        lw $a3, 16($sp)
        lw $t0, 20($sp)
        lw $t1, 24($sp)
        lw $t2, 28($sp)
        lw $t3, 32($sp)
        lw $t4, 36($sp)
        lw $t5, 40($sp)
        lw $t6, 44($sp)
        lw $t7, 48($sp)
        lw $t8, 52($sp)
        lw $t9, 56($sp)
        lw $s3, 60($sp)
        lw $s4, 64($sp)
        lw $s5, 68($sp)
        lw $s6, 72($sp)
        add $sp, $sp, 76

        bne $v0, 1, end_if_inner4       # if !(solve(puzzle, solution, next_row, next_col))
        li $v0, 1                     # return 1
        jr $ra

end_if_inner4:

        add $s0, $t5, $s6               # dominos_used[domino_code] offset
        lb $s1, 0($s0)                  # dominos_used[domino_code]
        li $s1, 0                       # dominos_used[domino_code] = 0
        lb $s1, 0($s0)                  # storing value back into memory

        move $t7, $zero                 # solution[row * num_cols + col] = 0
        sb $t7, 0($s3)                  # storing solution[row * num_cols + col]
        
        move $t9, $zero                 # solution[row * num_cols + (col + 1)] = 0
        sb $t9, 0($s5)                  # storing solution[row * num_cols + (col + 1)]


end_code:

        li $v0, 0                     # return 0

        jr      $ra


# // Constants
# #define MAX_GRIDSIZE = 16
# #define MAX_MAXDOTS = 15

# dominosa_question_size = 493 (4 + 4 + 4 + 256 + 225)

# // puzzle question structure
# typedef struct {
#     int num_rows;
#     int num_cols;
#     int max_dots;
#     unsigned char board[MAX_GRIDSIZE * MAX_GRIDSIZE];
#     unsigned char dominos_used[MAX_MAXDOTS * MAX_MAXDOTS];
# } dominosa_question;