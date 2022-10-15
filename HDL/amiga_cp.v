module amiga_cp(D, D_write, D_read, A, A_val, CS_n, INT6_n, IOWR_n, IORD_n, RESET_n, wait_states, RnW, request);

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
input logic RnW; // either read or write
input logic wait_states; // can be either (0 read/1 write) or (3 read/4 write)
input logic request; // either read or write
reg logic enable; // either read or write
reg logic output_enable = 0;

/*
        _____                                       _________
SPARE_CS     |______________1190ns__(770+420)______|
        _____________                          _________
_IORD          220ns |____720ns_(300+420)_____|
                                              ^940ns (520+420)
        ______________________                    _________
_IOWR          350ns          |__620ns_(200+420)_|
                                                 ^970ns (550+420)

        _____                                      _________
NET_CS       |______________770ns_________________|
        _____________                          _________
_IORD          220ns |_________300ns__________|
                                              ^520ns
        ______________________                   _________
_IOWR           350ns          |______200ns_____|
                                                ^550ns
*/

always @(posedge request) begin
  CS_n = 0;
  #140ns A = A_val;
  if(wait_states)
    #420ns CS_n = 0;
  #560ns
  A = 8'hz;
  #70ns
  CS_n = 1;
end

always @(posedge request)
if(RnW) begin
  #220ns
  IORD_n = 1'b0;
  if(wait_states)
    #420ns IORD_n = 1'b0;// 780ns /
  #100ns
  D_read = D;
  #200ns
  IORD_n = 1'b1;
end

always @(posedge request)
if(!RnW) begin
  #280ns
  output_enable = 1'b1;
  #70ns
  IOWR_n = 1'b0;
  if(wait_states)
    #420ns IOWR_n = 1'b0;// 780ns /
  #200ns
  IOWR_n = 1'b1;
  #70ns
  output_enable = 1'b0;
end

assign D = output_enable ? D_write : 8'hz;

endmodule
