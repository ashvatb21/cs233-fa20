// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC;  

    wire [31:0] nextPC, branchOffset, pcPlusFour, branch, jump;
    wire [31:0] extended_lui, mem_read_out, out, slt_out, data_out, chosen_byte, byte_load_out, extended_negative, B_out, W_data, addm_Data;
    wire [31:0] rsData, rtData, rdData;
    wire [31:0] imm_sign, imm_zero;
    wire [31:0] B;

    // control signals
    wire writeenable, rd_src, overflow, zero, negative, mem_read, word_we, byte_we, byte_load, lui, slt, addm;
    wire [1:0] alu_src2;
    wire [1:0] control_type;
    wire [2:0] alu_op;

    // register inputs
    wire [4:0] rs = inst[25:21];
    wire [4:0] rt = inst[20:16];
    wire [4:0] rd = inst[15:11];
    wire [4:0] W_addr;


    assign jump[31:28] = PC[31:28];
	assign jump[27:2] = inst[25:0];
    assign jump[1:0] = 0;

    assign extended_lui[31:16] = inst[15:0];
    assign extended_lui[15:0] = 0;

    assign extended_negative[31:1] = 0;
    assign extended_negative[0] = negative;

    assign chosen_byte[31:8] = 0;



    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(32) PC_reg(PC, nextPC, clock, 1'b1, reset);

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory im(inst[31:0], PC[31:2]);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (rsData, rtData, rs, rt, W_addr, rdData, writeenable, clock, reset);

    mips_decode md1(alu_op, writeenable, rd_src, alu_src2, except, control_type, mem_read, word_we, byte_we, byte_load, slt, lui, addm, inst[31:26], inst[5:0], zero);
    instruction_memory im1(inst[31:0], PC[31:2]);
    data_mem dm1(data_out[31:0], out[31:0], rtData[31:0], word_we, byte_we, clock, reset);

    alu32 pcplus4(pcPlusFour, , , , PC, 32'h4, `ALU_ADD);
    alu32 branching(branch, , , , pcPlusFour, branchOffset, `ALU_ADD);
    alu32 mainAlu(out, overflow, zero, negative, rsData, B, alu_op);



    mux2v #(5) m_rd_src(W_addr, rd, rt, rd_src);
    mux2v #(32) m_lui(W_data, mem_read_out, extended_lui, lui);
    mux2v #(32) m_slt(slt_out, out, extended_negative, slt);
    mux2v #(32) m_mem_read(mem_read_out, slt_out, byte_load_out, mem_read);
    mux2v #(32) m_byte_load(byte_load_out, data_out, chosen_byte, byte_load);
    mux3v #(32) m_alu_src2(B, rtData, imm_sign, imm_zero, alu_src2);
    mux4v #(32) m_control_type(nextPC, pcPlusFour, branch, jump, rsData, control_type);
    mux4v #(32) m_out(chosen_byte[7:0], data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24], out[1:0]);
   

    /* add other modules */

    sign_extender s1(imm_sign, inst[15:0]);
    zero_extender z1(imm_zero, inst[15:0]);
    bitShiftLeft_2 bsl2(branchOffset, imm_sign);

endmodule // full_machine

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

module bitShiftLeft_2 (branchOffset, imm_sign);
   output [31:0] branchOffset;
   input [31:0] imm_sign;
   assign branchOffset[31:2] = imm_sign[29:0];
   assign branchOffset[1:0] = 0;

endmodule // shift_left_two
