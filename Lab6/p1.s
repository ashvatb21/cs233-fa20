# Sets the values of the array to the corresponding values in the request
# void fill_array(unsigned request, int* array) {
#   for (int i = 0; i < 6; ++i) {
#     request >>= 3;
#
#     if (i % 3 == 0) {
#       array[i] = request & 0x0000001f;
#     } else {
#       array[i] = request & 0x000000ff;
#     }
#   }
# }
.globl fill_array
fill_array:

    li $t0, 0                   # int i = 0
    li $t9, 3                   # arbitrary register storing integer 3

for_loop:

    bge $t0, 6, end_loop        # loop condition

    srl $a0, $a0, 3             # request >>= 3
    rem $t1, $t0, $t9           # i % 3

    mul $t2, $t0, 4             # 4*i 
    add $t3, $a1, $t2           # integer offset for array

if:
    bne $t1, 0, else            # if (i % 3 == 0)

    lw $t4, 0($t3)              # storing array[i]
    and $t4, $a0, 0x0000001f    # array[i] = request & 0x0000001f
    sw $t4, 0($t3)              # storing array[i] in memory

    add $t0, $t0, 1             # i++

    j for_loop

else:

    lw $t4, 0($t3)              # storing array[i]
    and $t4, $a0, 0x000000ff    # array[i] = request & 0x000000ff
    sw $t4, 0($t3)              # storing array[i] in memory

    add $t0, $t0, 1             # i++

    j for_loop


end_loop:
    jr      $ra
