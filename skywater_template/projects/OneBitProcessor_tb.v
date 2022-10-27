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

	// Max number of insructions in any file that will be loaded in this tb
	parameter MAX_INSTRUCTION_LENGTH = 6;
	// Instructions read in from the file
	reg[12:0] read_in_data [ MAX_INSTRUCTION_LENGTH:0];  
	OneBitProcessor dut (
		.clk(clk),
		.reset(reset),
		.en(enable),
		.inReg(input_signals),
		.outReg(regs_out));

	// Vals for test1:
	reg[12:0] testInstr;
	integer i;

	initial begin
		$display($time, " << Starting the Simulation");
		clk = 0;
		reset = 0;
		enable = 0;

		// Test 1: Load instructions:

		// Reset dut
		reset = 1;
		clk = ~clk;
		clk = ~clk;
		reset = 0;
		//begin by loading sime arbitrart values into the instruction memory:
		input_signals[0] = 1;
		enable = 1;
		for(i = 0; i < 13; i = i + 1) begin // Cycle the clk 13 time to fill the first instruction positon with 1s
			#10 clk = ~clk;
			#10 clk = ~clk;
		end	

		input_signals[0] = 0;
		for(i = 0; i < 13; i = i + 1) begin // Same as before, but 0s this time
			#10 clk = ~clk;
			#10 clk = ~clk;
		end	

		input_signals[0] = 0;
		for(i = 0; i < 13; i = i + 1) begin // Now, alternate bits
			input_signals[0] = ~input_signals[0];
			#10 clk = ~clk;
			#10 clk = ~clk;
		end	

		input_signals[0] = 1;
		for(i = 0; i < 13; i = i + 1) begin // And the otehr way
			input_signals[0] = ~input_signals[0];
			#10 clk = ~clk;
			#10 clk = ~clk;
		end	

		/*
		if (dut.instruction1Loc == 1111111111111)
			$print("MemLoc1 good");
		else
			$print("MemLoc1 not good");

		if (dut.instruction2Loc == 0000000000000)
			$print("MemLoc2 good");
		else
			$print("MemLoc2 not good");

		if (dut.instruction1Loc == 1010101010101)
			$print("MemLoc3 good");
		else
			$print("MemLoc3 not good");

		if (dut.instruction1Loc == 0101010101010)
			$print("MemLoc4 good");
		else
			$print("MemLoc4 not good");
		*/


		// Test 2: load a simple program
		// First, load instructions from .1bin file
		//$readmemb("test.1bin", read_in_data);

		
	end

endmodule
	