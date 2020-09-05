module alu1_test;
    // exhaustively test your 1-bit ALU implementation by adapting mux4_tb.v

    // cycle through all combinations of A, B, C every 8 time units
    reg A = 0;
    always #1 A = !A;
    reg B = 0;
    always #2 B = !B;
    reg C = 0;
    always #4 C = !C;

    reg [2:0] control = 0;

    initial begin
        $dumpfile("alu1.vcd");
        $dumpvars(0, alu1_test);

        // control is initially 0
        # 8 control = 1; // UNDEFINED (O and 1)
        # 8 control = 2; // ADD
        # 8 control = 3; // SUBTRACT
        # 8 control = 4; // AND
        # 8 control = 5; // OR
        # 8 control = 6; // NOR
        # 8 control = 7; // XOR
        # 8 $finish; // wait 8 time units and then end the simulation
    end

    wire out, carryout;
    alu1 al1(out, carryout, A, B, C, control);

    // you really should be using gtkwave instead
    
    initial begin
        $display("ALU1 Test");
        $display("A B C s o Cout");
        $monitor("%d %d %d %d %d %d (at time %t)", A, B, C, control, out, carryout, $time);
    end

endmodule
