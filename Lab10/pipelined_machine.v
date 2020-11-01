module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target;
    wire [31:0]  inst;

    wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
    wire [4:0]   rs = inst[25:21];
    wire [4:0]   rt = inst[20:16];
    wire [4:0]   rd = inst[15:11];
    wire [5:0]   opcode = inst[31:26];
    wire [5:0]   funct = inst[5:0];

    wire [4:0]   wr_regnum;
    wire [2:0]   ALUOp;

    wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst;
    wire         PCSrc, zero;
    wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

    // New Wires
    wire [31:0]  alu_out_data_MW, rd2_data_MW;
    wire [31:0]  forwardA_out, forwardB_out;
    wire [31:0]  pre_inst, pre_PC_plus4;
    wire [4:0] wr_regnum_MW;
    wire ForwardA, ForwardB, RegWrite_MW, MemToReg_MW, MemRead_MW, MemWrite_MW;
    wire stall, stall_reset, flush, flush_reset, enable;

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */ enable, reset);

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    adder30 next_PC_adder(pre_PC_plus4, PC[31:2], 30'h1);
    register #(30) PC_plus4_r1(PC_plus4, pre_PC_plus4, clk, enable, flush_reset); //
    adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
    mux2v #(30) branch_mux(next_PC, pre_PC_plus4, PC_target, PCSrc);
    assign PCSrc = BEQ & zero;

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory imem(pre_inst, PC[31:2]);
    register #(32) inst_r1(inst, pre_inst, clk,enable, flush_reset); //
    mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst,
                      opcode, funct);

    register #(1) MemRead_MW_r1(MemRead_MW, MemRead, clk, 1'b1, flush_reset); //
    register #(1) RegWrite_MW_r1(RegWrite_MW, RegWrite,clk, 1'b1, flush_reset); //
    register #(1) MemWrite_MW_r1(MemWrite_MW, MemWrite, clk, 1'b1, flush_reset); //
    register #(1) MemToReg_MW_r1(MemToReg_MW, MemToReg, clk, 1'b1, flush_reset); //

    //register MemRead_reg(MemRead_MW,MemRead,clk,1'b1,reset);
    // DO NOT comment out or rename this modzule
    // or the test bench will break
    regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum_MW, wr_data,
               RegWrite_MW, clk, reset);

    mux2v #(32) ForwardA_mux(forwardA_out, rd1_data, alu_out_data_MW, ForwardA); //
    mux2v #(32) ForwardB_mux(forwardB_out, rd2_data, alu_out_data_MW, ForwardB); //
    register #(32) rd2_data_MW_r1(rd2_data_MW, forwardB_out, clk, 1'b1, stall_reset | flush); //

    mux2v #(32) imm_mux(B_data, forwardB_out, imm, ALUSrc);
    alu32 alu(alu_out_data, zero, ALUOp, forwardA_out, B_data);

    register #(32) alu_out_data_MW_r1(alu_out_data_MW, alu_out_data, clk, 1'b1, stall_reset | flush); //

    // DO NOT comment out or rename this module
    // or the test bench will break
    data_mem data_memory(load_data, alu_out_data_MW, rd2_data_MW, MemRead_MW, MemWrite_MW, clk, reset);

    mux2v #(32) wb_mux(wr_data, alu_out_data_MW, load_data, MemToReg_MW);
    mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

    register #(5) wr_regnum_MW_r1(wr_regnum_MW, wr_regnum, clk, 1'b1, stall_reset | flush); //


    // Forwarding
    wire w1 = rs == 0;
    wire w2 = rt == 0;
    wire w3 = rs == wr_regnum_MW;
    wire w4 = rt == wr_regnum_MW;
    assign ForwardA = ~w1 & w3 & RegWrite_MW;
    assign ForwardB = ~w2 & w4 & RegWrite_MW;

    // Stalling
    assign stall = (~w1 & w3 & MemRead_MW) | (~w2 & w4 & MemRead_MW);
    assign stall_reset = stall | reset;
    assign enable = ~stall;

    // Flushing
    assign flush = PCSrc;
    assign flush_reset = flush | reset;

endmodule // pipelined_machine
