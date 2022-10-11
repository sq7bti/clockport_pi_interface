`timescale 1ns/1ps

module cp_pi_if_test;

 // 100(?) MHz.
  logic CLK = 0;

  // inputs from clock-port
  input logic CS_n; // = 1'b1;
  input logic IORD_n; // = 1'b1;
  input logic IOWR_n; // = 1'b1;
  logic [3:0] CP_A = 4'b0;
  logic       INT6_n;
  output logic [7:0] D_write;
  inout logic [7:0] D_read;
  inout wire [1:0] A;
  inout wire [7:0] CP_Data;
  output logic [1:0] A_val;
  output logic RnW = 0;
  output logic request = 0;
  output logic wait_states = 1;

  // lines from Raspberry PI
  logic       PI_REQ = 1'b0;
  logic       PI_WR = 1'b0;
  logic [1:0] PI_A = 2'b0;
  logic       PI_IRQ;
  // output
  logic       PI_ACK;
  // inout
  logic [7:0] PI_D;

  // shared data bus
  inout logic [7:0] D;

  // latch control outputs
  input logic LE_OUT; // = 1'b0,
  input logic OE_IN_n; // = 1'b1,
  input logic OE_OUT_n; // !cp_rd

  // sram interface
  input logic [15:0] RAM_A;
  input logic RAM_OE_n; // = 1'b1,
  input logic RAM_WE_n; // = 1'b1

  // CP latches
  logic [7:0] cp_data;
  logic [7:0] cp_data_out;
  logic [7:0] pi_value;

  task cp_write_reg(input logic [1:0] register, input logic [7:0] value);
    begin
      // set reg 2 REG_A_LO to 55
      D_write = value;
      A_val = register;
      RnW = 1'b0;
      request = 1;
      #2us
      request = 0;
    end
  endtask

  task cp_read_reg(input logic [1:0] register);
    begin
      // read from SRAM
      //D_write = value;
      A_val = register;
      RnW = 1'b1;
      request = 1;
      #2us
      request = 0;
    end
  endtask

  task pi_write_reg(input logic [1:0] register, input logic [7:0] value);
    begin
      //# 1
      @(posedge CLK)
      // set reg 2 REG_A_LO to 55
      # 2ns PI_A = register;
      pi_value = value;
      PI_WR = 1;
      PI_REQ = 1;
      # 100ns PI_REQ = 0;
      PI_WR = 0;
    end
  endtask

  task pi_read_reg(input logic [1:0] register);
    begin
      //# 1
      @(posedge CLK)
      // read from SRAM
      # 2ns PI_A = register;
      PI_WR = 0;
      PI_REQ = 1;
      # 100ns PI_REQ = 0;
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

    $dumpfile("cp_pi_if_test.vcd");
    $dumpvars(0,cp_pi_if_test);

    // set irq reg
    //cp_write_reg(2'h1, 8'h0);

    // set reg 2 REG_A_LO to 55
    //cp_write_reg(2'h2, 8'h55);

     // set reg 3 REG_A_HI to AA
     //cp_write_reg(2'h3, 8'hAA);

     // read from SRAM
     //read_reg(2'h0);

     cp_write_mem(16'h1122, 8'hAA);
     cp_write_reg(2'h0, 8'hBB);
     cp_write_reg(2'h0, 8'hCC);
     cp_write_reg(2'h0, 8'hDD);
     # 100ns
     cp_read_mem(16'h1122);
     cp_read_reg(2'h0);
     cp_read_reg(2'h0);
     cp_read_reg(2'h0);

     //cp_write_mem(16'hBBAA, 8'hDD);
     //cp_read_mem(16'hBBAA);

     //cp_write_mem(16'hBBAA, 8'hEE);
     //cp_read_mem(16'hBBAA);

     //cp_write_mem(16'hBBAA, 8'hFF);
     //cp_read_mem(16'hBBAA);

     //# 100ns

     //pi_write_mem(16'h1234, 8'h78);
     //# 100ns
     //pi_read_mem(16'h1234);
     //pi_read_reg(2'h3);

     # 10ns $finish;
  end

  /* Make a regular pulsing clock. */
  //reg CLK = 0;
  always // 85MHz
     # 6ns CLK = !CLK;

  //assign D = IOWR_n ? 8'bz : (OE_IN_n ? 8'bz : cp_data);
  //assign CP_Data = IOWR_n ? 8'bz : (OE_IN_n ? 8'bz : cp_data);
  //assign CP_Data = IOWR_n ? 8'bz : cp_data;
  //assign D = IOWR_n ? 8'bz : cp_data;

  //assign PI_D = PI_REQ && PI_WR ? pi_value : 8'bz;

  cp_pi_if a314(CLK, CS_n, IORD_n, IOWR_n, A,
                PI_REQ, PI_WR, PI_A, PI_ACK,
                D,
                LE_OUT, OE_IN_n, OE_OUT_n,
                PI_D,
                INT6_n, PI_IRQ,
                RAM_A, RAM_OE_n, RAM_WE_n);

  //                      /CE
  SRAM memory1 (RAM_A, D, 1'b0, RAM_WE_n, RAM_OE_n);

  // latch with outputs towards CP (IC2)
  latch latch_out(D, CP_Data, LE_OUT, OE_OUT_n);
  // latch with outputs towards A314 (IC3)
  latch latch_in(CP_Data, D, 1'b1, OE_IN_n);

  amiga_cp amiga_clock_port(CP_Data, D_write, D_read, A, A_val, CS_n, INT6_n, IOWR_n, IORD_n, RESET_n, wait_states, RnW, request);

  initial
    begin
     $monitor("At time %t, D = %h (%0d)",
              $time, D, D);
   end
endmodule // test
