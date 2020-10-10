# #define MAX_GRIDSIZE 16
# #define MAX_MAXDOTS 15

# /*** begin of the solution to the puzzle ***/

# // encode each domino as an int
# int encode_domino(unsigned char dots1, unsigned char dots2, int max_dots) {
#     return dots1 < dots2 ? dots1 * max_dots + dots2 + 1 : dots2 * max_dots + dots1 + 1;
# }
.globl encode_domino
encode_domino:

        sub $sp, $sp, 36                # Alloc Stack
        sw $ra, 0($sp)                  # Storing callee save values
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)
        sw $s5, 24($sp)
        sw $s6, 28($sp)
        sw $s7, 32($sp)

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
        
        sw $ra, 0($sp)                  # Restoring callee save values
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)
        sw $s5, 24($sp)
        sw $s6, 28($sp)
        sw $s7, 32($sp)
        add $sp, $sp, 36                # DeAlloc Stack

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

        # Plan out your registers and their lifetimes ahead of time. You will almost certainly run out of registers if you
        # do not plan how you will use them. If you find yourself reusing too much code, consider using the stack to store
        # some variables like &solution[row * num_cols + col] (caller-saved convention).

.globl solve
solve:

        sub $sp, $sp, 76                # Alloc Stack
        sw $ra, 0($sp)                  # Storing callee save values
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)
        sw $s5, 24($sp)
        sw $s6, 28($sp)
        sw $s7, 32($sp)

################################################################################
        # $a0 = dominosa_question* puzzle
        # $a1 = unsigned char* solution
        # $a2 = row
        # $a3 = col
        
        # $s0 = num_rows
        # $s1 = num_cols
        # $s2 = max_dots
        # $s3 = next_row
        # $s4 = next_col
        # $s5 = dominos_used*[]
        # $s6 = curr_dots
        # $s7 = domino_code

        # $t0 = solution[row * num_cols + col] offset
        # $t1 = solution[row * num_cols + col]
        # $t2 = solution[(row + 1) * num_cols + col] offset
        # $t3 = solution[(row + 1) * num_cols + col]
        # $t4 = solution[row * num_cols + (col + 1)] offset
        # $t5 = solution[row * num_cols + (col + 1)]

        # $t6 - $t9 = Temporaries
################################################################################

        lw $s0, 0($a0)                  # int num_rows = puzzle->num_rows
        lw $s1, 4($a0)                  # int num_cols = puzzle->num_cols
        lw $s2, 8($a0)                  # int max_dots = puzzle->max_dots

        sub $t7, $s1, 1                 # num_cols - 1

if_assign:

        bne $a3, $t7, else_assign       # !(col == num_cols - 1)
        add $s3, $a2, 1                 # int next_row = row + 1

        j end_assign

else_assign:

        move $s3, $a2                   # int next_row = row

end_assign:

        add $t7, $a3, 1                 # col + 1
        rem $s4, $t7, $s1               # int next_col = (col + 1) % num_cols

        la $s5, 268($a0)                # unsigned char* dominos_used = puzzle->dominos_used

if1_prep:

        bge $a2, $s0, if1               # if (row >= num_rows) ||
        blt $a3, $s1, end_if1           # if !(col >= num_cols)

if1:

        lw $ra, 0($sp)                  # Restoring callee save values
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        lw $s7, 32($sp)
        add $sp, $sp, 76                # DeAlloc Stack 

        li $v0, 1                       # return 1

        jr $ra

end_if1:

        # $t0 - $t5 Defines
        mul $t0, $a2, $s1               # row * num_cols
        add $t0, $t0, $a3               # [row * num_cols + col]
        add $t0, $t0, $a1               # solution[row * num_cols + col] offset
        lb $t1, 0($t0)                  # solution[row * num_cols + col]
        
        add $t2, $a2, 1                 # row + 1
        mul $t2, $t2, $s1               # (row + 1) * num_cols
        add $t2, $t2, $a3               # [(row + 1) * num_cols + col]
        add $t2, $t2, $a1               # solution[(row + 1) * num_cols + col] offset
        lb $t3, 0($t2)                  # solution[(row + 1) * num_cols + col]

        mul $t4, $a2, $s1               # row * num_cols
        add $t4, $t4, $a3               # [row * num_cols + col]
        add $t4, $t4, 1                 # [row * num_cols + (col + 1)]
        add $t4, $t4, $a1               # solution[row * num_cols + (col + 1)] offset
        lb $t5, 0($t4)                  # solution[row * num_cols + (col + 1)]        


if2:

        beq $t1, 0, end_if2             # if !(solution[row * num_cols + col] != 0)

        sw $a0, 36($sp)                 # Storing caller save values
        sw $a1, 40($sp)
        sw $a2, 44($sp)
        sw $a3, 48($sp)
        sw $t0, 52($sp)
        sw $t1, 56($sp)
        sw $t2, 60($sp)
        sw $t3, 64($sp)
        sw $t4, 68($sp)
        sw $t5, 72($sp)

        move $a2, $s3                   # next_row
        move $s3, $s4                   # next_col

        jal solve                       # solve(puzzle, solution, next_row, next_col)

        lw $ra, 0($sp)                  # Restoring caller save values
        lw $a0, 36($sp)                 
        lw $a1, 40($sp)
        lw $a2, 44($sp)
        lw $a3, 48($sp)
        lw $t0, 52($sp)
        lw $t1, 56($sp)
        lw $t2, 60($sp)
        lw $t3, 64($sp)
        lw $t4, 68($sp)
        lw $t5, 72($sp)

        lw $ra, 0($sp)                  # Restoring callee save values
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        lw $s7, 32($sp)
        add $sp, $sp, 76                # DeAlloc Stack

        jr $ra

end_if2:

        mul $t7, $a2, $s1               # row * num_cols
        add $t7, $t7, $a3               # [row * num_cols + col]
        la $t8, 12($a0)                 # Address of puzzle->board[0]
        add $t8, $t8, $t7               # Offset for board[row * num_cols + col]
        lb $s6, 0($t8)                  # unsigned char curr_dots = puzzle->board[row * num_cols + col]


        # FIRST BIG IF SECTION


if_outer1:

        sub $t7, $s0, 1                 # num_rows - 1

        bge $a2, $t7, if_outer2         # if !(row < num_rows - 1) &&
        bne $t3, 0, if_outer2           # if !( solution[(row + 1) * num_cols + col] == 0)

        sw $a0, 36($sp)                 # Storing caller save values
        sw $a1, 40($sp)
        sw $a2, 44($sp)
        sw $a3, 48($sp)
        sw $t0, 52($sp)
        sw $t1, 56($sp)
        sw $t2, 60($sp)
        sw $t3, 64($sp)
        sw $t4, 68($sp)
        sw $t5, 72($sp)

        add $t7, $a2, 1                 # row + 1
        mul $t7, $t7, $s1               # (row + 1) * num_cols
        add $t7, $t7, $a3               # [(row + 1) * num_cols + col]
        la $t8, 12($a0)                 # Address of puzzle->board[0]
        add $t8, $t8, $t7               # Offset for board[(row + 1) * num_cols + col]
        lb $t9, 0($t8)                  # puzzle->board[(row + 1) * num_cols + col]

        move $a0, $s6                   # curr_dots
        move $a1, $t9                   # puzzle->board[(row + 1) * num_cols + col]
        move $a2, $s2                   # max_dots

        jal encode_domino

        lw $ra, 0($sp)                  # Restoring caller save values
        lw $a0, 36($sp)                 
        lw $a1, 40($sp)
        lw $a2, 44($sp)
        lw $a3, 48($sp)
        lw $t0, 52($sp)
        lw $t1, 56($sp)
        lw $t2, 60($sp)
        lw $t3, 64($sp)
        lw $t4, 68($sp)
        lw $t5, 72($sp)

        move $s7, $v0                   # int domino_code

if_inner1:

        add $t7, $s5, $s7               # dominos_used[domino_code] offset
        lb $t8, 0($t7)                  # dominos_used[domino_code]

        bne $t8, 0, end_if_inner1       # if !(dominos_used[domino_code] == 0)

        li $t8, 1                       # dominos_used[domino_code] = 1
        sb $t8, 0($t7)                  # storing dominos_used[domino_code]

        move $t1, $s7                   # solution[row * num_cols + col] = domino_code
        sb $t1, 0($t0)                  # storing solution[row * num_cols + col]
        
        move $t3, $s7                   # solution[(row + 1) * num_cols + col] = domino_code
        sb $t3, 0($t2)                  # storing solution[(row + 1) * num_cols + col] 

if_inner_inner1:

        sw $a0, 36($sp)                 # Storing caller save values
        sw $a1, 40($sp)
        sw $a2, 44($sp)
        sw $a3, 48($sp)
        sw $t0, 52($sp)
        sw $t1, 56($sp)
        sw $t2, 60($sp)
        sw $t3, 64($sp)
        sw $t4, 68($sp)
        sw $t5, 72($sp)

        move $a2, $s3                   # next_row
        move $a3, $s4                   # next_col

        jal solve

        lw $ra, 0($sp)                  # Restoring caller save values
        lw $a0, 36($sp)                 
        lw $a1, 40($sp)
        lw $a2, 44($sp)
        lw $a3, 48($sp)
        lw $t0, 52($sp)
        lw $t1, 56($sp)
        lw $t2, 60($sp)
        lw $t3, 64($sp)
        lw $t4, 68($sp)
        lw $t5, 72($sp)

        bne $v0, 1, end_if_inner_inner1 # if !(solve(puzzle, solution, next_row, next_col))       

        lw $ra, 0($sp)                  # Restoring callee save values
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        lw $s7, 32($sp)
        add $sp, $sp, 76                # DeAlloc Stack

        li $v0, 1                       # return 1
        jr $ra

end_if_inner_inner1:

        add $t7, $s5, $s7               # dominos_used[domino_code] offset
        lb $t8, 0($t7)                  # dominos_used[domino_code]
        li $t8, 0                       # dominos_used[domino_code] = 0
        sb $t8, 0($t7)                  # storing dominos_used[domino_code]

        li $t1, 0                       # solution[row * num_cols + col] = 0
        sb $t1, 0($t0)                  # storing solution[row * num_cols + col]
        
        li $t3, 0                       # solution[(row + 1) * num_cols + col] = 0
        sb $t3, 0($t2)                  # storing solution[(row + 1) * num_cols + col] 

end_if_inner1:

        # NO COMMANDS


        # SECOND BIG IF SECTION


if_outer2:

        sub $t7, $s1, 1                 # num_col - 1

        bge $a3, $t7, end_solve         # if !(col < num_col - 1) &&
        bne $t4, 0, end_solve           # if !( solution[row * num_cols + (col + 1)] == 0)

        sw $a0, 36($sp)                 # Storing caller save values
        sw $a1, 40($sp)
        sw $a2, 44($sp)
        sw $a3, 48($sp)
        sw $t0, 52($sp)
        sw $t1, 56($sp)
        sw $t2, 60($sp)
        sw $t3, 64($sp)
        sw $t4, 68($sp)
        sw $t5, 72($sp)

        mul $t7, $a2, $s1               # row * num_cols
        add $t7, $t7, $a3               # [row * num_cols + col]
        add $t7, $t7, 1                 # [row * num_cols + (col + 1)]
        la $t8, 12($a0)                 # Address of puzzle->board[0]
        add $t8, $t8, $t7               # Offset for board[row * num_cols + (col + 1)]
        lb $t9, 0($t8)                  # puzzle->board[row * num_cols + (col + 1)]

        move $a0, $s6                   # curr_dots
        move $a1, $t9                   # puzzle->board[(row + 1) * num_cols + col]
        move $a2, $s2                   # max_dots

        jal encode_domino

        lw $ra, 0($sp)                  # Restoring caller save values
        lw $a0, 36($sp)                 
        lw $a1, 40($sp)
        lw $a2, 44($sp)
        lw $a3, 48($sp)
        lw $t0, 52($sp)
        lw $t1, 56($sp)
        lw $t2, 60($sp)
        lw $t3, 64($sp)
        lw $t4, 68($sp)
        lw $t5, 72($sp)

        move $s7, $v0                   # int domino_code

if_inner2:

        add $t7, $s5, $s7               # dominos_used[domino_code] offset
        lb $t8, 0($t7)                  # dominos_used[domino_code]

        bne $t8, 0, end_if_inner2       # if !(dominos_used[domino_code] == 0)

        li $t8, 1                       # dominos_used[domino_code] = 1
        sb $t8, 0($t7)                  # storing dominos_used[domino_code]

        move $t1, $s7                   # solution[row * num_cols + col] = domino_code
        sb $t1, 0($t0)                  # storing solution[row * num_cols + col]
        
        move $t5, $s7                   # solution[row * num_cols + (col + 1)] = domino_code
        sb $t5, 0($t4)                  # storing solution[row * num_cols + (col + 1)] 

if_inner_inner2:

        sw $a0, 36($sp)                 # Storing caller save values
        sw $a1, 40($sp)
        sw $a2, 44($sp)
        sw $a3, 48($sp)
        sw $t0, 52($sp)
        sw $t1, 56($sp)
        sw $t2, 60($sp)
        sw $t3, 64($sp)
        sw $t4, 68($sp)
        sw $t5, 72($sp)

        move $a2, $s3                   # next_row
        move $a3, $s4                   # next_col

        jal solve

        lw $ra, 0($sp)                  # Restoring caller save values
        lw $a0, 36($sp)                 
        lw $a1, 40($sp)
        lw $a2, 44($sp)
        lw $a3, 48($sp)
        lw $t0, 52($sp)
        lw $t1, 56($sp)
        lw $t2, 60($sp)
        lw $t3, 64($sp)
        lw $t4, 68($sp)
        lw $t5, 72($sp)

        bne $v0, 1, end_if_inner_inner2 # if !(solve(puzzle, solution, next_row, next_col))       

        lw $ra, 0($sp)                  # Restoring callee save values
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        lw $s7, 32($sp)
        add $sp, $sp, 76                # DeAlloc Stack

        li $v0, 1                       # return 1
        jr $ra

end_if_inner_inner2:

        add $t7, $s5, $s7               # dominos_used[domino_code] offset
        lb $t8, 0($t7)                  # dominos_used[domino_code]
        li $t8, 0                       # dominos_used[domino_code] = 0
        sb $t8, 0($t7)                  # storing dominos_used[domino_code]

        li $t1, 0                       # solution[row * num_cols + col] = 0
        sb $t1, 0($t0)                  # storing solution[row * num_cols + col]
        
        li $t5, 0                       # solution[row * num_cols + (col + 1)] = 0
        sb $t5, 0($t4)                  # storing solution[row * num_cols + (col + 1)]

end_if_inner2:

        # NO COMMANDS

end_solve:

        lw $ra, 0($sp)                  # Restoring callee save values
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        lw $s7, 32($sp)
        add $sp, $sp, 76

        li $v0, 0                       # return 0

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