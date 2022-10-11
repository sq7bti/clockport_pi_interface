module SRAM(A, D, CS, WE, OE);

input [15:0] A;
inout [7:0] D;
input CS, WE, OE;

reg [7:0] Memory [0:65535];

assign D = (!CS && !OE) ? Memory[A] : 8'bz;

always @(CS or WE)
  if (!CS && !WE) begin
    //if ($countbits(D,'z)) begin
    if ($isunknown(D)) begin
      $display("invalid write in SRAM[%x]: %x", A, D);
      #1
      Memory[A] = D;
    end else begin
      Memory[A] = D;
      $display("Write in SRAM[%x]: %x", A, D);
    end
  end

always @(WE or OE)
  if (!WE && !OE)
    $display("Operational error in SRAM: OE and WE both active");

initial begin
  integer unsigned i;
  for (i = 0; i < 65536; i = i + 1)
    Memory[i] = 8'h0;
end

endmodule
