//implement a test bench for your 32-bit ALU
module alu32_test;
    reg [31:0] A = 0, B = 0;
    reg [2:0] control = 0;

    initial begin
        $dumpfile("alu32.vcd");
        $dumpvars(0, alu32_test);
             A = 8; B = 4; control = `ALU_ADD; // try adding 8 and 4
        # 10 A = 2; B = 5; control = `ALU_SUB; // try subtracting 5 from 2
        // add more test cases here!

        # 10 A = 32'h3f0f0f0f; B = 32'h30f0f0f0; control = `ALU_ADD; // Testing Addition
        # 10 A = 32'h3f0f0f0f; B = 32'h30f0f0f0; control = `ALU_SUB; // Testing Subtraction
        # 10 A = 32'h3f0f0f0f; B = 32'h30f0f0f0; control = `ALU_AND; // Testing AND
        # 10 A = 32'h3f0f0f0f; B = 32'h30f0f0f0; control = `ALU_OR; // Testing OR
        # 10 A = 32'h3f0f0f0f; B = 32'h30f0f0f0; control = `ALU_NOR; // Testing NOR
        # 10 A = 32'h3f0f0f0f; B = 32'h30f0f0f0; control = `ALU_XOR; // Testing XOR

        # 10 A = 32'h7fffffff; B = 32'h7fffffff; control = `ALU_SUB; // Testing subtracting number from itself  
        
        # 10 A = 21; B = 32'h7fffffff; control = `ALU_SUB; // Subtracting a large positive number from small positive number
        
        # 10 A = 32'h7fffffff; B = 32'h7fffffff; control = `ALU_ADD; // Addition of 2 large positive numbers
        # 10 A = 32'h80000000; B = 32'h80000000; control = `ALU_ADD; // Addition of 2 large negative numbers
        # 10 A = 32'h7fffffff; B = 32'h80000000; control = `ALU_SUB; // Subtracting large negative number from large positive number

        // Inputs for Quiz
        # 10 A = 32'h6591b0cf; B = 32'hd2ce6982; control = 3'b100;

        # 10 $finish;
    end

    wire [31:0] out;
    wire overflow, zero, negative;
    alu32 a(out, overflow, zero, negative, A, B, control); 

    initial begin
        $display("     A           B    s   Output   o z -");
        $display("");
        $monitor("%d %d %d %d %d %d %d (at time %t)", A, B, control, out, overflow, zero, negative, $time);
    end

endmodule // alu32_test
