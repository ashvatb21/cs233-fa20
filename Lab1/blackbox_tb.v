module blackbox_test;

	reg o, v, l;

	wire a;

	blackbox bx1(a, o, v, l);


	initial begin

		$dumpfile("blackbox.vcd");
		$dumpvars(0, blackbox_test);

		o = 0; v = 0; l = 0; # 10;
		o = 0; v = 0; l = 1; # 10;
		o = 0; v = 1; l = 0; # 10;
		o = 0; v = 1; l = 1; # 10;
		o = 1; v = 0; l = 0; # 10;
		o = 1; v = 0; l = 1; # 10;
		o = 1; v = 1; l = 0; # 10;
		o = 1; v = 1; l = 1; # 10;

		$finish;

	end

	initial begin
		$display("inputs = o, v, l  outputs = a");
		$monitor("At time %2t, a = %d o = %d v = %d l = %d", $time, a, o, v, l);
	end

endmodule // blackbox_test
