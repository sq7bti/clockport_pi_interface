`timescale 1ns/1ps

module test;

  parameter MEM_A_BITS = 16;
  parameter MEM_SIZE = (2 ** MEM_A_BITS);
 // 100(?) MHz.
  logic CLK = 0;

  // inputs from clock-port
  logic RTC_CS_n = 1'b1;
  logic IORD_n = 1'b1;
  logic IOWR_n = 1'b1;
  logic [1:0] CP_A = 2'b0;

  logic PI_REQ = 1'b0;
  logic PI_WR = 1'b0;
  logic [1:0] PI_A = 2'b0;

  // output
  input logic PI_ACK;
  // inout
  inout wire [7:0] D;
  // output
  input logic LE_OUT; // = 1'b0,
  input logic OE_IN_n; // = 1'b1,
  input logic OE_OUT_n; // !cp_rd
  // inout
  inout logic [7:0] PI_D;
  // output
  input logic INT6_n;
  input logic PI_IRQ;

  input logic [15:0] RAM_A;
  input logic RAM_OE_n; // = 1'b1,
  input logic RAM_WE_n; // = 1'b1

  logic [7:0] SRAM [MEM_SIZE - 1:0]; // = {65536{8'h00}};

  logic [7:0] cp_data;
  logic [7:0] pi_value;

  task cp_write_reg(input logic [1:0] register, input logic [7:0] value);
    begin
      // set reg 2 REG_A_LO to 55
      @(posedge CLK)
      CP_A = register;
      //D <= 8'h55;
      cp_data = value;
      IOWR_n = 0;
      # 1 RTC_CS_n = 0;
      # 16 RTC_CS_n = 1;
      # 1 IOWR_n = 1;
    end
  endtask

  task cp_read_reg(input logic [1:0] register);
    begin
      // read from SRAM
      //# 1
      @(posedge CLK)
      CP_A = register;
      IORD_n = 0;
      # 1 RTC_CS_n = 0;
      //# 10 value = D;
      # 16 RTC_CS_n = 1;
      # 1 IORD_n = 1;
    end
  endtask

  task pi_write_reg(input logic [1:0] register, input logic [7:0] value);
    begin
      //# 1
      @(posedge CLK)
      // set reg 2 REG_A_LO to 55
      PI_A = register;
      //D <= 8'h55;
      pi_value = value;
      PI_WR = 1;
      # 1 PI_REQ = 1;
      # 20 PI_REQ = 0;
    end
  endtask

  task pi_read_reg(input logic [1:0] register);
    begin
      //# 1
      @(posedge CLK)
      // read from SRAM
      PI_A = register;
      PI_WR = 0;
      # 1 PI_REQ = 1;
      # 20 PI_REQ = 0;
    end
  endtask

  task cp_write_mem(input logic [15:0] address, input logic [7:0] value);
    begin
    cp_write_reg(2'h2, address[7:0]);
    cp_write_reg(2'h3, address[15:8]);
    cp_write_reg(2'h0, value);
    end
  endtask

  task cp_read_mem(input logic [15:0] address);
    begin
    cp_write_reg(2'h2, address[7:0]);
    cp_write_reg(2'h3, address[15:8]);
    cp_read_reg(2'h0);
    end
  endtask

  task pi_write_mem(input logic [15:0] address, input logic [7:0] value);
    begin
    pi_write_reg(2'h2, address[7:0]);
    pi_write_reg(2'h3, address[15:8]);
    pi_write_reg(2'h0, value);
    end
  endtask

  task pi_read_mem(input logic [15:0] address);
    begin
    pi_write_reg(2'h2, address[7:0]);
    pi_write_reg(2'h3, address[15:8]);
    pi_read_reg(2'h0);
    end
  endtask

  integer unsigned i;
  initial begin
    for (i = 0; i < MEM_SIZE; i = i + 1)
      SRAM[i] = 8'h0;

    $dumpfile("test.vcd");
    $dumpvars(0,test);

    $display("memory address bus width %d", MEM_A_BITS);
    $display("memory size %d", MEM_SIZE);

    // set irq reg
    //cp_write_reg(2'h1, 8'h0);

    // set reg 2 REG_A_LO to 55
    //cp_write_reg(2'h2, 8'h55);

     // set reg 3 REG_A_HI to AA
     //cp_write_reg(2'h3, 8'hAA);

     // read from SRAM
     //read_reg(2'h0);

     cp_write_mem(16'hBBAA, 8'hCC);
     # 15
     cp_read_mem(16'hBBAA);

     //cp_write_mem(16'hBBAA, 8'hDD);
     //cp_read_mem(16'hBBAA);

     //cp_write_mem(16'hBBAA, 8'hEE);
     //cp_read_mem(16'hBBAA);

     //cp_write_mem(16'hBBAA, 8'hFF);
     //cp_read_mem(16'hBBAA);

     # 15

     pi_write_mem(16'h1234, 8'h78);
     # 15
     pi_read_mem(16'h1234);
     //pi_read_reg(2'h3);

     # 50ns $finish;
  end

  /* Make a regular pulsing clock. */
  //reg CLK = 0;
  always
     # 1 CLK = !CLK;

  always @(negedge RAM_WE_n)
  begin
    SRAM[RAM_A] = D;
  end

  //assign D = IOWR_n ? ( !LE_OUT && RAM_OE_n ? 8'bz : SRAM[RAM_A] ) : cp_date;
  assign D = IOWR_n ? ( RAM_OE_n ? 8'bz : SRAM[RAM_A] ) : (OE_IN_n ? 8'hz : cp_data);
  //assign D = IOWR_n ? ( RAM_OE_n ? 8'bz : SRAM ) : cp_data;
  assign PI_D = PI_REQ && PI_WR ? pi_value : 8'bz;

  cp_pi_if cp1 (CLK, RTC_CS_n, IORD_n, IOWR_n, CP_A, PI_REQ, PI_WR, PI_A, PI_ACK, D, LE_OUT, OE_IN_n, OE_OUT_n, PI_D, INT6_n, PI_IRQ, RAM_A, RAM_OE_n, RAM_WE_n);

  initial
    begin
     $monitor("At time %t, D = %h (%0d)",
              $time, D, D);
   end
endmodule // test
