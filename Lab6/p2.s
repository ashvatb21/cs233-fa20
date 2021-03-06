# Performs a selection sort on the data with a comparator
# void selection_sort (int* array, int len) {
#   for (int i = 0; i < len -1; i++) {
#     int min_idx = i;
#
#     for (int j = i+1; j < len; j++) {
#       // Do NOT inline compare! You code will not work without calling compare.
#       if (compare(array[j], array[min_idx])) {
#         min_idx = j;
#       }
#     }
#
#     if (min_idx != i) {
#       int tmp = array[i];
#       array[i] = array[min_idx];
#       array[min_idx] = tmp;
#     }
#   }
# }
.globl selection_sort
selection_sort:

    sub $sp, $sp, 28                # Alloc Stack
    sw $ra, 0($sp)                  # storing return address onto stack

    li $t0, 0                       # int i = 0
    sub $t1, $a1, 1                 # len - 1

outer_for:

    bge $t0, $t1, end_outer_for     # outer for loop condition
    move $t2, $t0                   # int min_idx = i

    add $t3, $t0, 1                 # int j = i+1

inner_for:

    bge $t3, $a1, end_inner_for     # inner for loop condition

    mul $t4, $t3, 4                 # offset for j
    add $t4, $a0, $t4               # offset(j)
    lw $t5, 0($t4)                  # array[j]

    mul $t6, $t2, 4                 # offset for min_idx
    add $t6, $a0, $t6               # offset(min_idx)
    lw $t7, 0($t6)                  # array[min_idx]

    sw $a0, 4($sp)                  # storing array onto stack
    sw $a1, 8($sp)                  # storing len onto stack

    sw $t0, 12($sp)                 # storing $t registers onto stack, as they're updated by the compare
    sw $t1, 16($sp)
    sw $t2, 20($sp)
    sw $t3, 24($sp)

    move $a0, $t5                   # input1 = array[j]
    move $a1, $t7                   # input2 = array[min_idx]

    jal compare                     # compare(array[j], array[min_idx])

    lw $t3, 24($sp)                 # loading $t registers from the stack after compare
    lw $t2, 20($sp)
    lw $t1, 16($sp)
    lw $t0, 12($sp)

    lw $a1, 8($sp)                  # loading len from stack
    lw $a0, 4($sp)                  # loading array from stack

if1:

    bne $v0, 1, end_if1             # if (compare(array[j], array[min_idx]))
    move $t2, $t3                   # min_idx = j

end_if1:

    add $t3, $t3, 1                 # j++
    j inner_for

end_inner_for:

if2:

    beq $t2, $t0, end_if2           # if (min_idx != i)

    mul $t4, $t0, 4                 # offset for i
    add $t4, $a0, $t4               # offset(i)
    lw $t5, 0($t4)                  # array[i]

    mul $t6, $t2, 4                 # offset for min_idx
    add $t6, $a0, $t6               # offset(min_idx)
    lw $t7, 0($t6)                  # array[min_idx]

    move $t8, $t5                   # int tmp = array[i]
    move $t5, $t7                   # array[i] = array[min_idx]
    move $t7, $t8                   # array[min_idx] = tmp;

    sw $t5, 0($t4)                  # Storing the value of array[i] back into the array
    sw $t7, 0($t6)                  # Stroing the value of array[min_idx] back into the array

end_if2:

    add $t0, $t0, 1                 # i++
    j outer_for

end_outer_for:

end:

    lw $ra, 0($sp)                  # loading return address from stack
    add $sp, $sp, 28                # DeAlloc Stack

    jr      $ra



# Draws points onto the array
# int draw_gradient(Gradient map[15][15]) {
#   int num_changed = 0;
#   for (int i = 0 ; i < 15 ; ++ i) {
#     for (int j = 0 ; j < 15 ; ++ j) {
#       char orig = map[i][j].repr;
#
#       if (map[i][j].xdir == 0 && map[i][j].ydir == 0) {
#         map[i][j].repr = '.';
#       }
#       if (map[i][j].xdir != 0 && map[i][j].ydir == 0) {
#         map[i][j].repr = '_';
#       }
#       if (map[i][j].xdir == 0 && map[i][j].ydir != 0) {
#         map[i][j].repr = '|';
#       }
#       if (map[i][j].xdir * map[i][j].ydir > 0) {
#         map[i][j].repr = '/';
#       }
#       if (map[i][j].xdir * map[i][j].ydir < 0) {
#         map[i][j].repr = '\';
#       }

#       if (map[i][j].repr != orig) {
#         num_changed += 1;
#       }
#     }
#   }
#   return num_changed;
# }
.globl draw_gradient
draw_gradient:

    li $t0, 0                       # int num_changed = 0
    li $t1, 0                       # int i = 0

outer_loop:

    bge $t1, 15, end_outer_loop     # outer for loop condition
    li $t2, 0                       # int j = 0

inner_loop:

    bge $t2, 15, end_inner_loop     # inner for loop condition

    mul $t3, $t1, 15                # i*15
    add $t3, $t3, $t2               # (i*15) + j  (1D indexing for 2D array of 15 rows)
    mul $t3, $t3, 12                # Offset for map[i][j] = 12 bytes
    add $t3, $a0, $t3               # Offset index for map[i][j]

    lb $t4, 0($t3)                  # loading map[i][j].repr onto register
    lw $t5, 4($t3)                  # loading map[i][j].xdir onto register
    lw $t6, 8($t3)                  # loading map[i][j].ydir onto register

    move $t7, $t4                   # char orig = map[i][j].repr

if_1:

    bne $t5, 0, if_2                # if (map[i][j].xdir == 0 && map[i][j].ydir == 0)
    bne $t6, 0, if_2
    li $t4, '.'                     # map[i][j].repr = '.'

if_2:

    beq $t5, 0, if_3                # if (map[i][j].xdir != 0 && map[i][j].ydir == 0)
    bne $t6, 0, if_3
    li $t4, '_'                     # map[i][j].repr = '_'

if_3:

    bne $t5, 0, if_4                # if (map[i][j].xdir == 0 && map[i][j].ydir != 0)
    beq $t6, 0, if_4
    li $t4, '|'                     # map[i][j].repr = '|'

if_4:

    mul $t8, $t5, $t6               # map[i][j].xdir * map[i][j].ydir
    ble $t8, 0, if_5                # if (map[i][j].xdir * map[i][j].ydir > 0)
    li $t4, '/'                     # map[i][j].repr = '/'

if_5:

    mul $t8, $t5, $t6               # map[i][j].xdir * map[i][j].ydir
    bge $t8, 0, if_6                # if (map[i][j].xdir * map[i][j].ydir > 0)
    li $t4, '\\'                    # map[i][j].repr = '\'

if_6:

    beq $t4, $t7, end_if            # if (map[i][j].repr != orig)
    add $t0, $t0, 1                 # num_changed += 1

end_if:

    sb $t4, 0($t3)                  # storing updated map[i][j].repr back into struct
    add $t2, $t2, 1                 # j++

    j inner_loop

end_inner_loop:

    add $t1, $t1, 1                 # i++

    j outer_loop

end_outer_loop:

    move $v0, $t0
    jr      $ra

# repr P P P xdir xdir xdir xdir ydir ydir ydir ydir

# index A[row][col] = A[row ??? N COLS + col]

# typedef struct {
#   char repr;
#   int xdir;
#   int ydir;
# } Gradient;
