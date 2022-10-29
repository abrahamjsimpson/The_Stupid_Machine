/*
Matthew Crump
ECE5710, Fall 2022
The Stupid Machine, a 1-Bit Processor
Test Bench
Tests for the OneBitProcessor and associated sub-modules
*/
`timescale 1 ns / 100 ps

module OneBitProcessor_tb;

	reg clk;
	initial begin
		$display($time, " << Starting the Simulation");
		clk = 0;
		forever #5 clk = ~clk;
	end

	// Maximum number if instructions that any test will load
	integer MAX_INSTRUCTION_LENGTH = 5;

	//  TEST 1:

	// inputs to the DUT
	reg reset1;
	reg enable1;
	reg [1:0] input_signals1;
	// outputs from the DUT
	wire [6:0] regs_out1;

	// Instructions read in from the file
	//reg[12:0] read_in_data [ MAX_INSTRUCTION_LENGTH:0];  
	OneBitProcessor dut1 (
		.clk(clk),
		.reset(reset1),
		.en(enable1),
		.inReg(input_signals1),
		.outReg(regs_out1));

	// Vals for test1:
	reg[12:0] testInstr;
	integer i;


	initial begin
		reset1 = 0;
		enable1 = 0;

		// Test 1: Load instructions:

		// Reset dut
		reset1 = 1;
		clk = ~clk;
		clk = ~clk;
		reset1 = 0;
		//begin by loading sime arbitrart values into the instruction memory:
		input_signals1[0] = 1;
		enable1 = 1;
		// Wait 13 periods so a full instruction is just 1s
		#130

		input_signals1[0] = 0;
		// Same as before, but 0s this time
		#130

		input_signals1[0] = 0;
		for(i = 0; i < 13; i = i + 1) begin // Now, alternate bits
			#10 input_signals1[0] = ~input_signals1[0];
		end	

		input_signals1[0] = 1;
		for(i = 0; i < 13; i = i + 1) begin // And the otehr way
			#10 input_signals1[0] = ~input_signals1[0];
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

	// TEST 2: Run a simple program
	// inputs to the DUT
	reg reset2;
	reg enable2;
	reg [1:0] input_signals2;
	// outputs from the DUT
	wire [6:0] regs_out2;
  
	OneBitProcessor dut2 (
		.clk(clk),
		.reset(reset2),
		.en(enable2),
		.inReg(input_signals2),
		.outReg(regs_out2));

	integer fd_test2;
	reg[6*13:0] instructions2;

	initial begin
		// load instructions from file
		fd_test2 = $fopen(insert absolute file path, "r");
		while (! $feof(fd_test2)) begin
			$fgets(instructions2, fd_test2);
			$display("%0s", instructions2);
		end
		$fclose(fd_test2);

	end


endmodule
	