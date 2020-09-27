.data

request1: .word 0xf0f0f0f0
test1: .space 24

request2: .word 0x12345678
test2: .space 24

request3: .word 0xAAAAAAAA
test3: .space 24

.text

print_array:
    li      $t0, 0          # Loop index
    move    $t1, $a0        # Array pointer

loop:
    bge     $t0, 6, loop_end

    # Print current int
    li      $v0, 1
    lw      $a0, ($t1)
    syscall
    li      $v0, 11
    li      $a0, ' '
    syscall

    add     $t1, $t1, 4     # Next int
    add     $t0, $t0, 1     # Next index

    j       loop

loop_end:
    li      $v0, 11
    li      $a0, '\n'
    syscall
    jr      $ra

main:
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)

    ### TESTCASE  1 ###

    lw      $a0, request1
    la      $a1, test1
    jal     fill_array

    # Expected:  30 195 120 15 225 60
    la      $a0, test1
    jal     print_array

    ### TESTCASE  2 ###

    lw      $a0, request2
    la      $a1, test2
    jal     fill_array

    # Expected:  15 89 43 5 104 141
    la      $a0, test2
    jal     print_array

    ### TESTCASE  3 ###

    lw      $a0, request3
    la      $a1, test3
    jal     fill_array

    # Expected:  21 170 85 10 85 170
    la      $a0, test3
    jal     print_array

    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr      $ra
