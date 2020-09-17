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

    // assign alu_src2 = ((opcode == `OP_OTHER0) ? 2'b00 : ((opcode == `OP_ADDI) ? 2'b01 : ((opcode == `OP_ANDI | opcode == `OP_ORI | opcode == `OP_XORI) ? 2'b10 : 2'b11)));
    assign alu_src2 = ((opcode == `OP_OTHER0) ? 2'b00 : ((w_addi) ? 2'b01 : ((w_andi | w_ori | w_xori) ? 2'b10 : 2'b11)));
    assign writeenable = (w_add | w_sub | w_and | w_or | w_nor | w_xor | w_addi | w_andi | w_ori | w_xori);
    assign rd_src = (w_addi | w_andi | w_ori | w_xori);
    assign except = ~writeenable;

    assign alu_op[0] = (w_sub | w_or | w_xor | w_ori | w_xori);
    assign alu_op[1] = (w_add | w_sub | w_nor | w_xor | w_addi | w_xori);
    assign alu_op[2] = (w_and | w_or | w_nor | w_xor | w_andi | w_ori | w_xori);

endmodule // mips_decode
