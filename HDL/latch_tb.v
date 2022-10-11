`timescale 1ns/1ps

module latch_test;

  output logic [7:0] D;
  input logic [7:0] Q;
  // active high
  output logic LE = 1'b0;
  // active low
  output logic OE_n = 1'b1;

  integer unsigned i = 0;

  always begin
    #1 D = i;
    i = i + 1;
    if (i > 255)
      i = 0;
  end

  always begin
    #5 LE = !LE;
  end

  always begin
    #7 OE_n = !OE_n;
  end

  initial begin

    $dumpfile("latch_test.vcd");
    $dumpvars(0,latch_test);

    # 125

    # 10 $finish;
  end

  latch dl1 (D, Q, LE, OE_n);

endmodule // test
