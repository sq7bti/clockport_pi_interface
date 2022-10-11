module latch(D, Q, LE, OE_n);

input logic [7:0] D;
output wire [7:0] Q;
input logic LE, OE_n;

reg [7:0] d_latch;

assign Q = (!OE_n) ? d_latch : 8'bz;

always @(LE or D)
  if (LE)
    d_latch = D;

endmodule
