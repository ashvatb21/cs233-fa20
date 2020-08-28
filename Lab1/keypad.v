module keypad(valid, number, a, b, c, d, e, f, g);

   // inputs, outputs and wires
   output valid;
   output [3:0] number;
   input  a, b, c, d, e, f, g;
   wire   w1, w2;

   // Determining valid key press
   and andAG(w1, a, g); // Key press left of 0
   and andCG(w2, c, g); // Key press right of 0
   or Valid(valid, w1, w2, b, d, e, f);

   // Assigning number


endmodule // keypad
