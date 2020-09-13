
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, zero_length_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array, zero_length_array;
	input clock, reset;

	wire garbage, sorting_complete, sorting_incomplete, w_LoadInput, increment_index;

	wire garbage_next = (~go & garbage) | reset;
	wire sorting_complete_next = ((~go & sorting_complete) | (increment_index & (end_of_array | zero_length_array))) & ~reset;
	wire sorting_incomplete_next = ((~go & sorting_incomplete) | (inversion_found & ~end_of_array & ~zero_length_array)) & ~reset;
	wire increment_index_next = ((~go & w_LoadInput) | (increment_index & ~inversion_found & ~end_of_array & ~zero_length_array)) & ~reset;
	wire w_LoadInput_next = go & (garbage | sorting_complete | sorting_incomplete | w_LoadInput) & ~reset;

	dffe d0(garbage, garbage_next, clock, 1'b1, 1'b0);
	dffe d1(sorting_complete, sorting_complete_next, clock, 1'b1, 1'b0);
	dffe d2(sorting_incomplete, sorting_incomplete_next, clock, 1'b1, 1'b0);
	dffe d3(increment_index, increment_index_next, clock, 1'b1, 1'b0);
	dffe d4(w_LoadInput, w_LoadInput_next, clock, 1'b1, 1'b0);

	assign sorted = sorting_complete;
	assign done = sorting_complete | sorting_incomplete;
	assign load_input = w_LoadInput;
	assign load_index = increment_index | w_LoadInput;
	assign select_index = increment_index;

endmodule
