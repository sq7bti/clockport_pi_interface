module latch(D, Q, LE, OE);

input logic [7:0] D;
output logic [7:0] Q;
input logic LE, OE;

reg [7:0] d_latch;

assign Q = (!OE) ? d_latch : 8'bz;

always @(LE or D)
  if (LE)
    d_latch = D;

endmodule
