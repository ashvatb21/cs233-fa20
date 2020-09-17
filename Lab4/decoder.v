// mips_decode: a decoder for MIPS arithmetic instructions
//
// rd_src      (output) - should the destination register be rd (0) or rt (1)
// writeenable (output) - should a new value be captured by the register file
// alu_src2    (output) - should the 2nd ALU source be a register (0), zero extended immediate or sign extended immediate
// alu_op      (output) - control signal to be sent to the ALU
// except      (output) - set to 1 when the opcode/funct combination is unrecognized
// opcode      (input)  - the opcode field from the instruction
// funct       (input)  - the function field from the instruction
//

module mips_decode(rd_src, writeenable, alu_src2, alu_op, except, opcode, funct);
    output       rd_src, writeenable, except;
    output [1:0] alu_src2;
    output [2:0] alu_op;
    input  [5:0] opcode, funct;

    wire w_add, w_sub, w_and, w_or, w_nor, w_xor, w_addi, w_andi, w_ori, w_xori;

    assign w_add = (opcode == `OP_OTHER0) & (funct = `OP0_ADD);
    assign w_sub = (opcode == `OP_OTHER0) & (funct = `OP0_SUB);
    assign w_and = (opcode == `OP_OTHER0) & (funct = `OP0_AND);
    assign w_or = (opcode == `OP_OTHER0) & (funct = `OP0_OR);
    assign w_nor = (opcode == `OP_OTHER0) & (funct = `OP0_NOR);
    assign w_xor = (opcode == `OP_OTHER0) & (funct = `OP0_XOR);

    assign w_addi = (opcode == `OP_ADDI);
    assign w_andi = (opcode == `OP_ANDI);
    assign w_ori = (opcode == `OP_ORI);
    assign w_xori = (opcode == `OP_XORI);

endmodule // mips_decode
