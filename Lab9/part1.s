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



.text
main:
# Construct interrupt mask
	li      $t4, 0
        or      $t4, $t4, REQUEST_PUZZLE_INT_MASK # puzzle interrupt bit
        or      $t4, $t4, TIMER_INT_MASK	  # timer interrupt bit
        or      $t4, $t4, BONK_INT_MASK           # timer interrupt bit
        or      $t4, $t4, 1                       # global enable
	mtc0    $t4, $12

#Fill in your code here

        sub     $sp, $sp, 8
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)

        # lw      $v0, 0xffff001c($0)             # read current time
        # add     $v0, $v0, 25000                    # add 50 to current time
        # sw      $v0, 0xffff001c($0)             # request timer interrupt in 50 cycles                

        li      $t0, 10
        sw      $t0, VELOCITY                   # drive

        li      $s0, 0

        # lw      $s1, BOT_X                      # x value
        # lw      $s2, BOT_Y                      # y value
        # bne     $s1, 4, end_if1
        # bne     $s2, 4, end_if1

        # li      $s0, 0
        # sw      $s0, VELOCITY

# end_if1:

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

        

        add $sp, $sp, 8
        jr $ra

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

        sw      $a1, 0xffff0060($zero)  # acknowledge interrupt

        li      $a0, 270                # ???
        sw      $a0, 0xffff0014 ($zero) # ???
        li      $a1, 0                  # ???
        sw      $a1, 0xffff0018 ($zero) # ???

        j       interrupt_dispatch      # see if other interrupts are waiting

request_puzzle_interrupt:
        sw      $0, REQUEST_PUZZLE_ACK
#Fill in your code here
        j	interrupt_dispatch

timer_interrupt:
        sw      $0, TIMER_ACK
#Fill in your code here

        sw      $a1, 0xffff006c($zero)   # acknowledge interrupt

        li      $a0, 0
        sw      $a0, 0xffff0010($zero)          # drive

        li      $t0, 90                  # ???
        sw      $t0, 0xffff0014($zero)   # ???
        li      $t0, 0
        sw      $t0, 0xffff0018($zero) # ???

        # lw      $v0, 0xffff001c($0)      # current time
        # add     $v0, $v0, 50000  
        # sw      $v0, 0xffff001c($0)      # request timer in 50000

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
