module keypad(valid, number, a, b, c, d, e, f, g);

   // inputs, outputs and wires
   output valid;
   output [3:0] number;
   input  a, b, c, d, e, f, g;
   wire   w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12;

   // Determining valid key press
   and andAG(w1, a, g); // Key press left of 0
   and andCG(w2, c, g); // Key press right of 0
   or Valid(valid, w1, w2, b, d, e, f);

   // Assigning number
   and andAD(w3, a, d);
   and andCD(w4, c, d);
   and andBE(w5, b ,e);
   and andAF(w6, a, f);
   and andCF(w7, c, f);
   or number_0(number[0], w3, w4, w5, w6, w7);

   and andBD(w8, b, d);
   and andCE(w9, c, e);
   and andAF(w10, a, f);
   or  number_1(number[1], w4, w6, w8, w9, w10);

   and andAE(w11, a, e);
   or number_2(number[2], w5, w6, w9, w11);

   and andBF(w12, b, f);
   or number_3(number[3], w7, w12);

endmodule // keypad
