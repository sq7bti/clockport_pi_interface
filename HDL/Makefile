V = iverilog
VVP = vvp

all: cp_pi_if_tb

clean:
	rm -rf cp_pi_if_tb cp_pi_if test.vcd

cp_pi_if_tb: cp_pi_if_tb.v cp_pi_if.v
	iverilog -g2012 -o $@ $^
	vvp $@
	#gtkwave test.vcd &
