// arith_machine: execute a series of arithmetic instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock  (input)  - the clock signal
// reset  (input)  - set to 1 to set all registers to zero, set to 0 for normal execution.

module arith_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC;  

    wire [31:0] nextPC;
    wire [31:0] B;

    wire [31:0] rsData;
    wire [31:0] rtData;
    wire [31:0] rdData;

    wire writeenable, rd_src, overflow, zero, negative;
    wire [1:0] alu_src2;
    wire [2:0] alu_op;

    wire [4:0] rs = inst[25:21];
    wire [4:0] rt = inst[20:16];
    wire [4:0] rd = inst[15:11];
    wire [4:0] W_addr;

    wire [31:0] imm_sign;
    wire [31:0] imm_zero;
    

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(32) PC_reg(PC, nextPC, clock, 1'b1, reset);

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory im(inst[31:0], PC[31:2]);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (rsData, rtData, rs, rt, W_addr, rdData, writeenable, clock, reset);

    alu32 pcplus4(nextPC, , , , PC, 32'h4, `ALU_ADD);
    alu32 a1(rdData, overflow, zero, negative, rsData, B, alu_op);
    mux2v #(5) m2(W_addr, rd, rt, rd_src);
    mux3v m3(B, rtData, imm_sign, imm_zero, alu_src2);
    sign_extender s1(imm_sign, inst[15:0]);
    zero_extender z1(imm_zero, inst[15:0]);
    mips_decode md1(rd_src, writeenable, alu_src2, alu_op, except, inst[31:26], inst[5:0]);


    /* add other modules */
   
endmodule // arith_machine

module sign_extender (imm_sign, inst);
    output [31:0] imm_sign;
    input [15:0] inst;
    assign imm_sign = {{16{inst[15]}}, inst[15:0]};

endmodule // sign_extender

module zero_extender (imm_zero, inst);
    output [31:0] imm_zero;
    input [15:0] inst;
    assign imm_zero = {{16{1'b0}}, inst[15:0]};

endmodule // zero_extender
