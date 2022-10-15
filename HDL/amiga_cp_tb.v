`timescale 1ns/1ps

module amiga_cp_test;

  output logic clk = 0;
  input wire [7:0] D;
  output logic [7:0] D_write = 8'h0;
  input logic [7:0] D_read;
  input logic [1:0] A;
  output logic [1:0] A_val = 8'h0;
  input logic CS_n;
  input logic IOWR_n;
  input logic IORD_n;
  output logic INT6_n;
  output logic RESET_n;
  // can be either:
  // low 0 read/1 write, or
  // high 3 read/4 write
  output logic wait_states = 0;
  // read or write operation checke only during state S0
  output logic RnW = 0;
  output logic request = 0;

  always @(posedge request)
  begin
    #1 D_write = D_write + 1;
  end

  always @(posedge request)
  begin
    #1 A_val = A_val + 1;
  end


  initial begin

    $dumpfile("amiga_cp_test.vcd");
    $dumpvars(0,amiga_cp_test);

    RnW = 1;
    wait_states = 0;

    #1us

    request = 1;
    #1 request = 0;

    #3us

    wait_states = 1;
    RnW = 1;

    #1us

    request = 1;
    #1 request = 0;

    #3us

    wait_states = 0;
    RnW = 0;

    #1us

    request = 1;
    #1 request = 0;

    #3us

    wait_states = 1;
    RnW = 0;

    #1us

    request = 1;
    #1 request = 0;

    #2us

    #10 $finish;
  end

  amiga_cp acp1(D, D_write, D_read, A, A_val, CS_n, INT6_n, IOWR_n, IORD_n, RESET_n, wait_states, RnW, request);

endmodule // test
