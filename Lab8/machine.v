module machine(clk, reset);
   input        clk, reset;

   wire [31:0]  PC;
   wire [31:2]  next_PC, PC_plus4, PC_target;
   wire [31:0]  inst;

   wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
   wire [4:0]   rs = inst[25:21];
   wire [4:0]   rt = inst[20:16];
   wire [4:0]   rd = inst[15:11];

   wire [4:0]   wr_regnum;
   wire [2:0]   ALUOp;

   wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET;
   wire         PCSrc, zero, negative;
   wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

   //Your extra wires go here
   wire TimerInterrupt, TimerAddress, TakenInterrupt;
   wire [31:0] c0_rd_data, cycle;
   wire [31:2] TakenInterrupt_muxOut;
   wire [29:0] ERET_muxOut;
   wire [29:0] EPC;

   wire NotIO;
   wire actual_MemRead;
   wire actual_MemWrite;

   wire [31:0] wb_in, MemToReg_muxOut;

   // register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */1'b1, reset);
   register #(30, 30'h100000) PC_reg(PC[31:2], TakenInterrupt_muxOut[31:2], clk, /* enable */1'b1, reset);
   assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
   adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
   adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
   mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
   assign PCSrc = BEQ & zero;

   instruction_memory imem (inst, PC[31:2]);

   mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET,
                      inst);

   regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum, wr_data,
               RegWrite, clk, reset);

   mux2v #(32) imm_mux(B_data, rd2_data, imm, ALUSrc);
   alu32 alu(alu_out_data, zero, negative, ALUOp, rd1_data, B_data);

   // data_mem data_memory(load_data, alu_out_data, rd2_data, MemRead, MemWrite, clk, reset);
   data_mem data_memory(load_data, alu_out_data, rd2_data, actual_MemRead, actual_MemWrite, clk, reset);

   // // mux2v #(32) wb_mux(wr_data, alu_out_data, load_data, MemToReg);
   mux2v #(32) wb_mux(MemToReg_muxOut, alu_out_data, wb_in, MemToReg);

   mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);
   
   //Connect your new modules below

   assign NotIO = ~TimerAddress;
   assign actual_MemRead = MemRead & NotIO;
   assign actual_MemWrite = MemWrite & NotIO;

   assign wb_in = load_data;
   assign wb_in = cycle;

   mux2v #(32) mux1(wr_data, MemToReg_muxOut, c0_rd_data, MFC0);
   mux2v #(30) mux2(ERET_muxOut, next_PC, EPC, ERET);
   mux2v #(30) mux3(TakenInterrupt_muxOut, ERET_muxOut, 30'h20000060, TakenInterrupt);

   timer t1(TimerInterrupt, cycle, TimerAddress, rd2_data, alu_out_data, MemRead, MemWrite, clk, reset);
   cp0 c1(c0_rd_data, EPC, TakenInterrupt, rd2_data, wr_regnum, next_PC, MTC0, ERET, TimerInterrupt, clk, reset);

endmodule // machine
