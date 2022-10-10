`timescale 1ns/1ps

module sram_test;

  output logic [15:0] A = 16'h0;
  inout logic [7:0] D;
  logic [7:0] data_value;
  output logic CS = 1'b1;
  output logic WE = 1'b1;
  output logic OE = 1'b1;

  integer unsigned i = 0, j = 0;

  task ram_write(input logic [15:0] target, input logic [7:0] value);
    begin
      // set reg 2 REG_A_LO to 55
      A = target;
      data_value = value;
      WE = 0;
      //#1
      CS = 0;
      # 10ns
      CS = 1;
      WE = 1;
    end
  endtask

  task ram_read(input logic [15:0] target);
    begin
      // read from SRAM
      A = target;
      OE = 0;
      //#1
      CS = 0;
      # 10ns
      CS = 1;
      //#1
      OE = 1;
    end
  endtask

  initial begin

    $dumpfile("sram_test.vcd");
    $dumpvars(0,sram_test);

    for (int i = 0; i < 16; i = i + 1) begin
      #10ns
      ram_write(i, i);
    end
    #10ns
    for (int i = 0; i < 16; i = i + 1) begin
      #10ns
      ram_read(i);
    end
    # 10ns $finish;
  end

  assign D = WE ? 8'bz : data_value;

  SRAM memory1 (A, D, CS, WE, OE);

  initial
    begin
     $monitor("At time %t, D = %h (%0d)",
              $time, D, D);
   end
endmodule // test
