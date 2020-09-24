module decoder_test;
    reg [5:0] opcode, funct;
    reg       zero  = 0;

    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, decoder_test);

        // remember that all your instructions from last week should still work
             opcode = `OP_OTHER0; funct = `OP0_ADD; // see if addition still works
        # 10 opcode = `OP_OTHER0; funct = `OP0_SUB; // see if subtraction still works
        // test all of the others here
        # 10 opcode = `OP_OTHER0; funct = `OP0_AND; // try and
        # 10 opcode = `OP_OTHER0; funct = `OP0_OR; // try or
        # 10 opcode = `OP_OTHER0; funct = `OP0_NOR; // try nor
        # 10 opcode = `OP_OTHER0; funct = `OP0_XOR; // try xor
        # 10 opcode = `OP_ADDI; // try immediate addition
        # 10 opcode = `OP_ANDI; // try immediate add
        # 10 opcode = `OP_ORI; // try immediate or
        # 10 opcode = `OP_XORI; // try immediate xor
        
        // as should all the new instructions from this week
        # 10 opcode = `OP_BEQ; zero = 0; // try a not taken beq
        # 10 opcode = `OP_BEQ; zero = 1; // try a taken beq

        // add more tests here!
        # 10 opcode = `OP_BNE; zero = 0; // try a taken bne
        # 10 opcode = `OP_BNE; zero = 1; // try a not taken bne
        # 10 opcode = `OP_J; zero = 0; // try j
        # 10 opcode = `OP_OTHER0; funct = `OP0_JR; zero = 1; // try jr
        # 10 opcode = `OP_LUI; zero = 0; // try lui
        # 10 opcode = `OP_OTHER0; funct = `OP0_SLT; zero = 1; // try slt
        # 10 opcode = `OP_LW; zero = 0; // try lw
        # 10 opcode = `OP_LBU; zero = 1; // try lbu
        # 10 opcode = `OP_SW; zero = 0; // try sw
        # 10 opcode = `OP_SB; zero = 1; // try sb
        # 10 opcode = `OP_OTHER0; funct = `OP0_ADDM; zero = 0; // try addm

        # 10 $finish;
    end

    // use gtkwave to test correctness
    wire [2:0] alu_op;
    wire [1:0] alu_src2;
    wire       writeenable, rd_src, except;
    wire [1:0] control_type;
    wire       mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    mips_decode decoder(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                        mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                        opcode, funct, zero);
endmodule // decoder_test
