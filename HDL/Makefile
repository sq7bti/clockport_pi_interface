V = iverilog
VVP = vvp

all: cp_pi_if_tb sram_tb latch_tb

clean:
	rm -rf cp_pi_if_tb cp_pi_if sram sram_tb latch latch_tb test.vcd

cp_pi_if_tb: cp_pi_if_tb.v cp_pi_if.v sram.v latch.v
	iverilog -g2012 -o $@ $^
	vvp $@
	pidof gtkwave || gtkwave cp_pi_if_test.vcd &

sram_tb: sram_tb.v sram.v
	iverilog -g2012 -o $@ $^
	vvp $@
	pidof gtkwave || gtkwave sram_test.vcd &

latch_tb: latch_tb.v latch.v
	iverilog -g2012 -o $@ $^
	vvp $@
	pidof gtkwave || gtkwave latch_test.vcd &
