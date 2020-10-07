# #define NULL 0

# // Note that the value of op_add is 0 and the value of each item
# // increments as you go down the list
# //
# // In C, an enum is just an int!
# typedef enum {
#     op_add,         
#     op_sub,         
#     op_mul,         
#     op_div,         
#     op_rem,         
#     op_neg,         
#     op_paren,
#     constant
# } node_type_t;

# typedef struct {
#     node_type_t type;
#     bool computed;
#     int value;
#     ast_node* left;
#     ast_node* right;
# } ast_node;

# int value(ast_node* node) {
#     if (node == NULL) { return 0; }
#     if (node->computed) { return node->value; }

#     int left = value(node->left);
#     int right = value(node->right);

#     // This can just implemented with successive if statements (see Appendix)
#     switch (node->type) {
#         case constant:
#             return node->value;
#         case op_add:
#             node->value = left + right;
#             break;
#         case op_sub:
#             node->value = left - right;
#             break;
#         case op_mul:
#             node->value = left * right;
#             break;
#         case op_div:
#             node->value = left / right;
#             break;
#         case op_rem:
#             node->value = left % right;
#             break;
#         case op_neg:
#             node->value = -left;
#             break;
#         case op_paren:
#             node->value = left;
#             break;
#     }
#     node->computed = true;
#     return node->value;
# }
.globl value
value:

if1:

        bne $a0, 0, end_if1             # if (node == NULL)
        li $v0, 0                       # return value 0
        jr $ra

end_if1:

        lw $t0, 0($a0)                  # node -> (node_type_t)type
        lb $t1, 4($a0)                  # node -> (bool)computed
        lw $t2, 8($a0)                  # node -> (int)value

        lw $t3, 12($a0)                 # node -> (asd_node*)left
        lw $t4, 16($a0)                 # node -> (asd_node*)right

if2:

        bne $t1, 1, end_if2             # if (node->computed)
        move $v0, $t2                   # return node->value
        jr $ra

end_if2:

        sub $sp, $sp, 28
        sw $ra 0($sp)
        sw $a0, 4($sp)
        sw $t0, 8($sp)
        sb $t1, 12($sp)
        sw $t2, 16($sp)
        sw $t3, 20($sp)
        sw $t4, 24($sp)

        move $a0, $t3                   # value(node->left)
        jal value
        move $t5, $v0                   # int left = value(node->left)

        lw $ra 0($sp)
        lw $a0, 4($sp)
        lw $t0, 8($sp)
        lb $t1, 12($sp)
        lw $t2, 16($sp)
        lw $t3, 20($sp)
        lw $t4, 24($sp)
        add $sp, $sp, 28


        sub $sp, $sp, 32
        sw $ra 0($sp)
        sw $a0, 4($sp)
        sw $t0, 8($sp)
        sb $t1, 12($sp)
        sw $t2, 16($sp)
        sw $t3, 20($sp)
        sw $t4, 24($sp)
        sw $t5, 28($sp)

        move $a0, $t4                   # value(node->right)
        jal value
        move $t6, $v0                   # int right = value(node->right)

        lw $ra 0($sp)
        lw $a0, 4($sp)
        lw $t0, 8($sp)
        lb $t1, 12($sp)
        lw $t2, 16($sp)
        lw $t3, 20($sp)
        lw $t4, 24($sp)
        lw $t5, 28($sp)
        add $sp, $sp, 32


case0:

        bne $t0, 0, case1               # case op_add
        add $t2, $t5, $t6               # node->value = left + right
        j end_switch

case1:

        bne $t0, 1, case2               # case op_sub
        sub $t2, $t5, $t6               # node->value = left - right
        j end_switch

case2:

        bne $t0, 2, case3               # case op_mul
        mul $t2, $t5, $t6               # node->value = left * right
        j end_switch

case3:

        bne $t0, 3, case4               # case op_div
        div $t2, $t5, $t6               # node->value = left / right
        j end_switch

case4:

        bne $t0, 4, case5               # case op_rem
        rem $t2, $t5, $t6               # node->value = left % right
        j end_switch

case5:

        bne $t0, 5, case6               # case op_neg
        sub $t2, $zero, $t5             # node->value = -left
        j end_switch

case6:

        bne $t0, 6, case7               # case op_paren
        move $t2, $t5                   # node->value = left
        j end_switch

case7:

        bne $t0, 7, end_switch          # case constant
        move $v0, $t2                   # return node->value
        jr $ra
        
end_switch:

        sw $t2, 8($a0)                  # storing value back into memory

        li $t1, 1                       # node->computed = true
        sb $t1, 4($a0)                  # storing computed back into memory

        move $v0, $t2                   # return node->value
        jr $ra