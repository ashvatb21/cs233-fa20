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
    jr      $ra
