.data
# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

TIMER                   = 0xffff001c

REQUEST_PUZZLE          = 0xffff00d0  ## Puzzle
SUBMIT_SOLUTION         = 0xffff00d4  ## Puzzle

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000      
TIMER_ACK               = 0xffff006c 

REQUEST_PUZZLE_INT_MASK = 0x800       ## Puzzle
REQUEST_PUZZLE_ACK      = 0xffff00d8  ## Puzzle

PICKUP                  = 0xffff00f4

### Puzzle
GRIDSIZE = 8
has_puzzle:        .word 0                         
puzzle:      .half 0:2000             
heap:        .half 0:2000
#### Puzzle

# # dominosa_question
# dominosa_question:
#         .word 

.text
main:
# Construct interrupt mask
	    li      $t4, 0
        or      $t4, $t4, REQUEST_PUZZLE_INT_MASK # puzzle interrupt bit
        or      $t4, $t4, TIMER_INT_MASK	  # timer interrupt bit
        or      $t4, $t4, BONK_INT_MASK	  # timer interrupt bit
        or      $t4, $t4, 1                       # global enable
	    mtc0    $t4, $12

#Fill in your code here

        sub     $sp, $sp, 40
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 12($sp)
        sw      $s2, 16($sp)
        sw      $s3, 20($sp)

# PART 2 CODE
puzzle_part:

        li      $s3, 0                          # int i = 0

for_puzzle:

        bge     $s3, 2, end_for_puzzle          # for !(int i = 0; i < 2; i++)

        la      $t0, puzzle                     # storing address of puzzle
        sw      $t0, REQUEST_PUZZLE             # Writing Address of start of puzzle to REQUEST_PUZZLE MMIO

        la      $t0, has_puzzle

while_puzzle:

        lw      $t1, 0($t0)                     # storing value of has_puzzle (puzzle_recieved)
        bne     $t1, 0, end_while_puzzle

        j       while_puzzle

end_while_puzzle:

        sw      $a0, 24($sp)
        sw      $a1, 28($sp)
        sw      $a2, 32($sp)
        sw      $a3, 36($sp)

        la      $a0, puzzle                     # loading address of the puzzle
        la      $a1, heap                       # loading address of solution
        li      $a2, 0                          # row = 0
        li      $a3, 0                          # column = 0

        jal solve

        lw      $a0, 24($sp)
        lw      $a1, 28($sp)
        lw      $a2, 32($sp)
        lw      $a3, 36($sp)

        la      $t0, heap
        sw      $t0, SUBMIT_SOLUTION

        add     $s3, $s3, 1                     # i++
        j for_puzzle


end_for_puzzle:




# PART 2 CODE END

# PART 1 CODE
collect_flags:

        li      $t0, 10
        sw      $t0, VELOCITY                   # drive

        li      $s0, 0                          # Number of corn ears picked up

        j infinite

move_east:

        sw      $zero, VELOCITY

        li      $t0, 0                         # Angle Value
        sw      $t0, ANGLE
        li      $t1, 1
        sw      $t1, ANGLE_CONTROL             # Absolute Angle

        li      $t2, 10
        sw      $t2, VELOCITY
        jr      $ra

move_south:

        sw      $zero, VELOCITY

        li      $t0, 90                         # Angle Value
        sw      $t0, ANGLE
        li      $t1, 1
        sw      $t1, ANGLE_CONTROL             # Absolute Angle

        li      $t2, 10
        sw      $t2, VELOCITY
        jr      $ra

move_west:

        sw      $zero, VELOCITY

        li      $t0, 180                         # Angle Value
        sw      $t0, ANGLE
        li      $t1, 1
        sw      $t1, ANGLE_CONTROL             # Absolute Angle

        li      $t2, 10
        sw      $t2, VELOCITY
        jr      $ra

move_north:

        sw      $zero, VELOCITY

        li      $t0, 270                         # Angle Value
        sw      $t0, ANGLE
        li      $t1, 1
        sw      $t1, ANGLE_CONTROL             # Absolute Angle

        li      $t2, 10
        sw      $t2, VELOCITY
        jr      $ra

infinite:

        lw      $s1, BOT_X                      # x value
        lw      $s2, BOT_Y                      # y value

if1:
        bne     $s0, 0, if2
        bne     $s1, 0x04, if2                  # Checking x value
        bne     $s2, 0x1c, if2                  # checking y value
        jal     move_east
        j       jump_infinite
if2:
        bne     $s0, 0, if3
        bne     $s1, 0x3c, if3
        bne     $s2, 0x1c, if3              
        jal     move_south
        j       jump_infinite
if3:
        bne     $s0, 0, if4
        bne     $s1, 0x3c, if4
        bne     $s2, 0x54, if4              
        jal     move_east
        j       jump_infinite
if4:
        bne     $s0, 0, if5
        bne     $s1, 0x5c, if5
        bne     $s2, 0x54, if5              
        jal     move_south
        j       jump_infinite
if5:
        bne     $s0, 0, pickup1
        bne     $s1, 0x5c, pickup1
        bne     $s2, 0x84, pickup1              
        jal     move_east
        j       jump_infinite
pickup1:
        bne     $s1, 0x6c, if6
        bne     $s2, 0x84, if6 
        li      $t0, 1
        sw      $t0, PICKUP
        li      $s0, 1   
        j       jump_infinite          
if6:
        bne     $s0, 1, if7
        bne     $s1, 0x74, if7
        bne     $s2, 0x84, if7              
        jal     move_south
        j       jump_infinite
if7:
        bne     $s0, 1, if8
        bne     $s1, 0x74, if8
        bne     $s2, 0xc4, if8              
        jal     move_east
        j       jump_infinite
if8:
        bne     $s0, 1, if9
        bne     $s1, 0x7c, if9
        bne     $s2, 0xc4, if9              
        jal     move_south
        j       jump_infinite
if9:
        bne     $s0, 1, if10
        bne     $s1, 0x7c, if10
        bne     $s2, 0xd4, if10             
        jal     move_west
        j       jump_infinite
if10:
        bne     $s0, 1, pickup2
        bne     $s1, 0x54, pickup2
        bne     $s2, 0xd4, pickup2          
        jal     move_south
        j       jump_infinite
pickup2:
        bne     $s1, 0x54, if11
        bne     $s2, 0xec, if11         
        li      $t0, 1
        sw      $t0, PICKUP
        li      $s0, 2
        jal     move_north
        j       jump_infinite
if11:
        bne     $s0, 2, if12
        bne     $s1, 0x54, if12
        bne     $s2, 0xd4, if12          
        jal     move_east
        j       jump_infinite
if12:
        bne     $s0, 2, if13
        bne     $s1, 0x7c, if13
        bne     $s2, 0xd4, if13             
        jal     move_north
        j       jump_infinite
if13:
        bne     $s0, 2, if14
        bne     $s1, 0x7c, if14
        bne     $s2, 0xb4, if14             
        jal     move_east
        j       jump_infinite
if14:
        bne     $s0, 2, pickup3
        bne     $s1, 0xdc, pickup3
        bne     $s2, 0xb4, pickup3          
        jal     move_south
        j       jump_infinite
pickup3:
        bne     $s0, 2, if15
        bne     $s1, 0xdc, if15
        bne     $s2, 0xbc, if15          
        li      $t0, 1
        sw      $t0, PICKUP
        li      $s0, 3   
        j       jump_infinite
if15:
        bne     $s0, 3, if16
        bne     $s1, 0xdc, if16
        bne     $s2, 0xcc, if16          
        jal     move_east
        j       jump_infinite
if16:
        bne     $s0, 3, if17
        bne     $s1, 0xfc, if17
        bne     $s2, 0xcc, if17          
        jal     move_south
        j       jump_infinite
if17:
        bne     $s0, 3, if18
        bne     $s1, 0xfc, if18
        bne     $s2, 0x104, if18          
        jal     move_east
        j       jump_infinite
if18:
        bne     $s0, 3, pickup4
        bne     $s1, 0x11c, pickup4
        bne     $s2, 0x104, pickup4         
        jal     move_south
        j       jump_infinite
pickup4:
        bne     $s0, 3, if19
        bne     $s1, 0x11c, if19
        bne     $s2, 0x114, if19         
        li      $t0, 1
        sw      $t0, PICKUP
        li      $s0, 4   
        j       jump_infinite
if19:
        
        

jump_infinite:
        j       infinite              # Don't remove this! If this is removed, then your code will not be graded!!!

        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 12($sp)
        lw      $s2, 16($sp)
        lw      $s3, 20($sp)
        add     $sp, $sp, 40
        jr      $ra



#
#
#
#
#
#
# The contents of this file are not graded, it exists purely as a reference solution that you can use


# #define MAX_GRIDSIZE 16
# #define MAX_MAXDOTS 15

# /*** begin of the solution to the puzzle ***/

# // encode each domino as an int
# int encode_domino(unsigned char dots1, unsigned char dots2, int max_dots) {
#     return dots1 < dots2 ? dots1 * max_dots + dots2 + 1 : dots2 * max_dots + dots1 + 1;
# }
encode_domino:
        bge     $a0, $a1, encode_domino_greater_row

        mul     $v0, $a0, $a2           # col * max_dots
        add     $v0, $v0, $a1           # col * max_dots + row
        add     $v0, $v0, 1             # col * max_dots + row + 1
        j       encode_domino_end
encode_domino_greater_row:
        mul     $v0, $a1, $a2           # row * max_dots
        add     $v0, $v0, $a0           # row * max_dots + col
        add     $v0, $v0, 1             # col * max_dots + row + 1
encode_domino_end:
        jr      $ra

# -------------------------------------------------------------------------
next:
        # $a0 = row
        # $a1 = col
        # $a2 = num_cols
        # $v0 = next_row
        # $v1 = next_col

        #     int next_row = ((col == num_cols - 1) ? row + 1 : row);
        move    $v0, $a0
        sub     $t0, $a2, 1
        bne     $a1, $t0, next_col
        add     $v0, $v0, 1
next_col:
        #     int next_col = (col + 1) % num_cols;
        add     $t1, $a1, 1
        rem     $v1, $t1, $a2

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
solve:
        sub     $sp, $sp, 80
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        sw      $s5, 24($sp)
        sw      $s6, 28($sp)
        sw      $s7, 32($sp)
        
        move    $s0, $a0                # puzzle
        move    $s1, $a1                # solution
        move    $s2, $a2                # row
        move    $s3, $a3                # col

#     int num_rows = puzzle->num_rows;
#     int num_cols = puzzle->num_cols;
#     int max_dots = puzzle->max_dots;
#     unsigned char* dominos_used = puzzle->dominos_used;
        lw      $s4, 0($s0)             # puzzle->num_rows
        lw      $s5, 4($s0)             # puzzle->num_cols
        lw      $s6, 8($s0)             # puzzle->max_dots
        la      $s7, 268($s0)           # puzzle->dominos_used

# Compute:
# - next_row (Done below)
# - next_col (Done below)
        mul     $t0, $s2, $s5
        add     $t0, $t0, $s3           # row * num_cols + col
        add     $t1, $s2, 1
        mul     $t1, $t1, $s5
        add     $t1, $t1, $s3           # (row + 1) * num_cols + col
        mul     $t2, $s2, $s5
        add     $t2, $t2, $s3
        add     $t2, $t2, 1             # row * num_cols + (col + 1)

        la      $t3, 12($s0)            # puzzle->board
        add     $t4, $t3, $t0
        lbu     $t9, 0($t4)
        sw      $t9, 44($sp)            # puzzle->board[row * num_cols + col]
        add     $t4, $t3, $t1
        lbu     $t9, 0($t4)
        sw      $t9, 48($sp)            # puzzle->board[(row + 1) * num_cols + col]
        add     $t4, $t3, $t2
        lbu     $t9, 0($t4)
        sw      $t9, 52($sp)            # puzzle->board[row * num_cols + (col + 1)]

        # solution addresses
        add     $t9, $s1, $t0
        sw      $t9, 56($sp)            # &solution[row * num_cols + col]
        add     $t9, $a1, $t1
        sw      $t9, 60($sp)            # &solution[(row + 1) * num_cols + col]
        add     $t9, $a1, $t2
        sw      $t9, 64($sp)            # &solution[row * num_cols + (col + 1)]


        #     int next_row = ((col == num_cols - 1) ? row + 1 : row);
        #     int next_col = (col + 1) % num_cols;
        move    $a0, $s2
        move    $a1, $s3
        move    $a2, $s5
        jal     next
        sw      $v0, 36($sp)
        sw      $v1, 40($sp)


#     if (row >= num_rows || col >= num_cols) { return 1; }
        sge     $t0, $s2, $s4
        sge     $t1, $s3, $s5
        or      $t0, $t0, $t1
        beq     $t0, 0, solve_not_base

        li      $v0, 1
        j       solve_end
solve_not_base:

#     if (solution[row * num_cols + col] != 0) { 
#         return solve(puzzle, solution, next_row, next_col); 
#     }
        lw      $t0, 56($sp)
        lb      $t0, 0($t0)
        beq     $t0, 0, solve_not_solved

        move    $a0, $s0
        move    $a1, $s1
        move    $a2, $v0
        move    $a3, $v1
        jal     solve
        j       solve_end

solve_not_solved:
#     unsigned char curr_dots = puzzle->board[row * num_cols + col];
        lw      $t9, 44($sp)            # puzzle->board[row * num_cols + col]

#     if (row < num_rows - 1 && solution[(row + 1) * num_cols + col] == 0) {
        sub     $t5, $s4, 1
        bge     $s2, $t5, end_vert

        lw      $t0, 60($sp)
        lbu     $t8, 0($t0)             # solution[(row + 1) * num_cols + col]
        bne     $t8, 0, end_vert 

#         int domino_code = encode_domino(curr_dots,
#                                         puzzle->board[(row + 1) * num_cols + col],
#                                         max_dots);
        move    $a0, $t9
        lw      $a1, 48($sp)
        move    $a2, $s6
        jal     encode_domino
        sw      $v0, 68($sp)

#         if (dominos_used[domino_code] == 0) {
        add     $t0, $s7, $v0
        lbu     $t1, 0($t0)
        bne     $t1, 0, end_vert

#             dominos_used[domino_code] = 1;
        li      $t1, 1
        sb      $t1, 0($t0)

#             solution[row * num_cols + col] = domino_code;
#             solution[(row + 1) * num_cols + col] = domino_code;
        lw      $t0, 56($sp)
        sb      $v0, 0($t0)
        lw      $t0, 60($sp)
        sb      $v0, 0($t0)

        
#             if (solve(puzzle, solution, next_row, next_col)) {
#                 return 1;
#             }
        move    $a0, $s0
        move    $a1, $s1
        lw      $a2, 36($sp)
        lw      $a3, 40($sp)
        jal     solve
        beq     $v0, 0, end_vert_if
        
        li      $v0, 1
        j       solve_end
end_vert_if:

#             dominos_used[domino_code] = 0;
        lw      $v0, 68($sp)            # domino_code
        add     $t0, $v0, $s7
        sb      $zero, 0($t0)
        
#             solution[row * num_cols + col] = 0;
        lw      $t0, 56($sp)
        sb      $zero, 0($t0)
#             solution[(row + 1) * num_cols + col] = 0;
        lw      $t0, 60($sp)
        sb      $zero, 0($t0)
#         }
#     }

end_vert:

#     if (col < num_cols - 1 && solution[row * num_cols + (col + 1)] == 0) {
        sub     $t5, $s5, 1
        bge     $s3, $t5, ret_0
        lw      $t0, 64($sp)
        lbu     $t1, 0($t0)             # solution[row * num_cols + (col + 1)]
        bne     $t1, 0, ret_0

#         int domino_code = encode_domino(curr_dots,
#                                         puzzle->board[row * num_cols + (col + 1)],
#                                         max_dots);
        lw      $a0, 44($sp)            # puzzle->board[row * num_cols + col]
        lw      $a1, 52($sp)
        move    $a2, $s6
        jal     encode_domino
        sw      $v0, 68($sp)

#         if (dominos_used[domino_code] == 0) {
        add     $t0, $s7, $v0
        lbu     $t1, 0($t0)
        bne     $t1, 0, ret_0
        
#             dominos_used[domino_code] = 1;
        li      $t1, 1
        sb      $t1, 0($t0)

#             solution[row * num_cols + col] = domino_code;
        lw      $t0, 56($sp)
        sb      $v0, 0($t0)
#             solution[row * num_cols + (col + 1)] = domino_code;
        lw      $t0, 64($sp)
        sb      $v0, 0($t0)
#             if (solve(puzzle, solution, next_row, next_col)) {
#                 return 1;
#             }
        move    $a0, $s0
        move    $a1, $s1
        lw      $a2, 36($sp)
        lw      $a3, 40($sp)
        jal     solve
        beq     $v0, 0, end_horz_if
        
        li      $v0, 1
        j       solve_end
end_horz_if:



#             dominos_used[domino_code] = 0;
        lw      $v0, 68($sp) # domino_code
        add     $t0, $s7, $v0 
        sb      $zero, 0($t0)
        
#             solution[row * num_cols + col] = 0;
        lw      $t0, 56($sp)
        sb      $zero, 0($t0)
#             solution[row * num_cols + (col + 1)] = 0;
        lw      $t0, 64($sp)
        sb      $zero, 0($t0)
#         }
#     }
#     return 0;
# }
ret_0:
        li      $v0, 0

solve_end:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        lw      $s5, 24($sp)
        lw      $s6, 28($sp)
        lw      $s7, 32($sp)
        add     $sp, $sp, 80
        jr      $ra



# // zero out an array with given number of elements
# void zero(int num_elements, unsigned char* array) {
#     for (int i = 0; i < num_elements; i++) {
#         array[i] = 0;
#     }
# }
zero:
        li      $t0, 0          # i = 0
zero_loop:
        bge     $t0, $a0, zero_end_loop
        add     $t1, $a1, $t0
        sb      $zero, 0($t1)
        add     $t0, $t0, 1
        j       zero_loop
zero_end_loop:
        jr      $ra




# // the slow solve entry function,
# // solution will appear in solution array
# // return value shows if the dominosa is solved or not
# int slow_solve_dominosa(dominosa_question* puzzle, unsigned char* solution) {
#     zero(puzzle->num_rows * puzzle->num_cols, solution);
#     zero(MAX_MAXDOTS * MAX_MAXDOTS, dominos_used);
#     return solve(puzzle, solution, 0, 0);
# }
# // end of solution
# /*** end of the solution to the puzzle ***/
slow_solve_dominosa:
        sub     $sp, $sp, 16
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)

        move    $s0, $a0
        move    $s1, $a1



#     zero(puzzle->num_rows * puzzle->num_cols, solution);
        lw      $t0, 0($s0)
        lw      $t1, 4($s0)
        mul     $a0, $t0, $t1
        jal     zero

#     zero(MAX_MAXDOTS * MAX_MAXDOTS + 1, dominos_used);
        li      $a0, 226
        la      $a1, 268($s0)
        jal     zero

#     return solve(puzzle, solution, 0, 0);
        move    $a0, $s0
        move    $a1, $s1
        li      $a2, 0
        li      $a3, 0
        jal     solve

        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        add     $sp, $sp, 16

        jr      $ra
#
#
#
#
#
#        

.kdata
chunkIH:    .space 8  #TODO: Decrease this
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
        move      $k1, $at              # Save $at
.set at
        la      $k0, chunkIH
        sw      $a0, 0($k0)             # Get some free registers
        sw      $v0, 4($k0)             # by storing them to a global variable

        mfc0    $k0, $13                # Get Cause register
        srl     $a0, $k0, 2
        and     $a0, $a0, 0xf           # ExcCode field
        bne     $a0, 0, non_intrpt

interrupt_dispatch:                     # Interrupt:
        mfc0    $k0, $13                # Get Cause register, again
        beq     $k0, 0, done            # handled all outstanding interrupts

        and     $a0, $k0, BONK_INT_MASK # is there a bonk interrupt?
        bne     $a0, 0, bonk_interrupt

        and     $a0, $k0, TIMER_INT_MASK # is there a timer interrupt?
        bne     $a0, 0, timer_interrupt

        and 	$a0, $k0, REQUEST_PUZZLE_INT_MASK
        bne 	$a0, 0, request_puzzle_interrupt

        li      $v0, PRINT_STRING       # Unhandled interrupt types
        la      $a0, unhandled_str
        syscall
        j       done

bonk_interrupt:
        sw      $0, BONK_ACK
#Fill in your code here
        j       interrupt_dispatch      # see if other interrupts are waiting

request_puzzle_interrupt:
        sw      $0, REQUEST_PUZZLE_ACK
#Fill in you code here

        # lw      $t0, REQUEST_PUZZLE_ACK
        li      $t1, 1
        sw      $t1, REQUEST_PUZZLE_ACK         # ACK the interrupt

        la      $t0, has_puzzle
        li      $t1, 1
        sw      $t1, 0($t0)                     # storing 1 into has_puzzle

        j	interrupt_dispatch

timer_interrupt:
        sw      $0, TIMER_ACK
#Fill in your code here
        j   interrupt_dispatch
non_intrpt:                             # was some non-interrupt
        li      $v0, PRINT_STRING
        la      $a0, non_intrpt_str
        syscall                         # print out an error message
# fall through to done

done:
        la      $k0, chunkIH
        lw      $a0, 0($k0)             # Restore saved registers
        lw      $v0, 4($k0)

.set noat
        move    $at, $k1                # Restore $at
.set at
        eret
