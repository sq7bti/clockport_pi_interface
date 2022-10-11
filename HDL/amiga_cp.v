module amiga_cp(D, D_write, D_read, A, A_val, CS_n, INT6_n, IOWR_n, IORD_n, RESET_n, wait_states, RnW, request);

output logic clk = 0;
output wire [7:0] D;
input logic [7:0] D_write;
output logic [7:0] D_read;
output logic [1:0] A;
input logic [1:0] A_val;
output logic CS_n = 1'b1;
output logic IOWR_n = 1'b1;
output logic IORD_n = 1'b1;
input logic INT6_n;
input logic RESET_n;
input logic wait_states; // can be either (0 read/1 write) or (3 read/4 write)
input logic RnW; // either read or write
input logic request; // either read or write
reg logic enable; // either read or write
reg logic output_enable = 0;

reg [3:0] state = 4'h0;
int wstate = 0;
logic rw_mode;

/* Make a regular pulsing clock. */
//reg CLK = 0;
always // 7MHz
   # 70ns clk = !clk;

always @(posedge request) begin
  enable <= 1'b1;
end

assign D = output_enable ? D_write : 8'hz;
//assign A = A_val;

always @(posedge clk) begin
  case (state)
    4'h0: if(enable) begin
      state <= state + 1;
      wstate = (RnW ? 0 : 1) + (wait_states ? 3 : 0);
      rw_mode = RnW;
      A = A_val;
      CS_n = 0;
    end
    4'h1:
      state <= state + 1;
    4'h2: begin
      state <= state + 1;
      if(rw_mode)
        IORD_n = 1'b0;
    end
    4'h3: begin
        state <= state + 1;
        if(!rw_mode)
          output_enable = 1;
      end
    4'h4:
      state <= state + 1;
    4'h5: begin
      state <= (wstate != 0) ? 4'hf : 4'h6;
      if(!rw_mode)
        IOWR_n = 1'b0;
    end
    4'h6:
      state <= state + 1;
    4'h7: begin
      state <= 4'h0;
      enable <= 1'b0;
      output_enable = 0;
      A = 8'hz;
      CS_n = 1;
      if(rw_mode)
        IORD_n = 1'b1;
    end
    4'hf: begin
      wstate = wstate - 1;
      if (wstate == 0) begin
        state <= 4'h6;
        if(!rw_mode)
          IOWR_n = 1'b1;
        else
          D_read <= D;
      end
    end
  endcase
end

endmodule
