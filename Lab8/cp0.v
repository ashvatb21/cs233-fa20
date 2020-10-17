`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;

    // your Verilog for coprocessor 0 goes herez

    wire [31:0] status_register, cause_register, user_status;
    wire [31:0] decoder_out, EPC_extended;
    wire [29:0] mux_TakenInterrupt_out;
    wire exception_level;
    wire ExceptionLevel_reset, EPC_enable;
    wire w0, w1, w2;


    assign status_register[31:16] = {16'b0};
    assign status_register[15:8] = user_status[15:8];
    assign status_register[7:2] = {6'b0};
    assign status_register[1] = exception_level;
    assign status_register[0] = user_status[0];

    assign cause_register[31:16] = {16'b0};
    assign cause_register[15] = TimerInterrupt;
    assign cause_register[14:0] = {15'b0};

    assign EPC_extended[31:2] = EPC[29:0];
    assign EPC_extended[1:0] = {2'b0};


    decoder32 d1(decoder_out, regnum, MTC0);

    register #(1) Exception_level(exception_level, 1'b1, clock, TakenInterrupt, ExceptionLevel_reset);
    register #(30) EPC_Register(EPC, mux_TakenInterrupt_out, clock, EPC_enable, reset);
    register #(32) User_status(user_status, wr_data, clock, decoder_out[12], reset);
    
    mux2v #(30) mux_TakenInterrupt(mux_TakenInterrupt_out, wr_data[31:2], next_pc, TakenInterrupt);
    mux3v #(32) mux_rd_data(rd_data, status_register, cause_register, EPC_extended, regnum[1:0]);

    or or_reset(ExceptionLevel_reset, reset, ERET);
    or or_enable(EPC_enable, decoder_out[14], TakenInterrupt);
    not not_status_register(w0, status_register[1]);
    and and_upperLeft(w1, cause_register[15], status_register[15]);
    and and_lowerLeft(w2, w0, status_register[0]);
    and and_TakenInterrupt(TakenInterrupt, w1, w2);

endmodule
