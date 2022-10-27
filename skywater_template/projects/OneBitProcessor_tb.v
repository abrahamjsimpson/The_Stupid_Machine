/*
Matthew Crump
ECE5710, Fall 2022
The Stupid Machine, a 1-Bit Processor
Test Bench
Tests for the OneBitProcessor and associated sub-modules
*/
`timescale 1 ns / 100 ps

module OneBitProcessor_tb;
	// inputs to the DUT
	reg clk;
	reg reset;
	reg enable;
	reg [1:0] input_signals;
	// outputs from the DUT
	wire [6:0] regs_out;

	OneBitProcessor dut (
		.clk(clk),
		.reset(reset),
		.en(enable),
		.inReg(input_signals),
		.outReg(regs_out));

	initial begin
		$display($time, " << Starting the Simulation");
		clk = 0;
		
	end

endmodule
	