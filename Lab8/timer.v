module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;

    // complete the timer circuit here

    wire [31:0] CycleCount_out, CycleCount_in, InterruptCycle_out;
    wire InterruptLine_reset, InterruptLine_enable;
    wire TimerRead, TimerWrite, Acknowledge;
    wire w0, w1;

    // HINT: make your interrupt cycle register reset to 32'hffffffff
    //       (using the reset_value parameter)
    //       to prevent an interrupt being raised the very first cycle

    assign InterruptLine_enable = (CycleCount_out == InterruptCycle_out);
    assign InterruptLine_reset = reset | Acknowledge;

    assign w0 = 32'hffff001c == address;
    assign w1 = 32'hffff006c == address;

    and a1(TimerRead, w0, MemRead);
    and a2(TimerWrite, w0, MemWrite);
    and a3(Acknowledge, w1, MemWrite);
    or o1(TimerAddress, w0, w1);

    assign TimerRead = w0 & MemRead;
    assign TimerWrite = w0 & MemWrite;
    assign Acknowledge = w1 & MemWrite;
    assign TimerAddress = w0 | w1;

    alu32 alu1(CycleCount_in, , ,`ALU_ADD, 32'b1, CycleCount_out);
    register #(32, 32'h0) cycle_counter(CycleCount_out, CycleCount_in, clock, 1'b1, reset);
    register #(32, 32'hffffffff) interrupt_counter(InterruptCycle_out, data ,clock ,TimerWrite , reset);
    tristate #(32) tristate1(cycle, CycleCount_out, TimerRead);
    dffe d1(TimerInterrupt, 1'b1, clock, InterruptLine_enable, InterruptLine_reset);

    

endmodule
