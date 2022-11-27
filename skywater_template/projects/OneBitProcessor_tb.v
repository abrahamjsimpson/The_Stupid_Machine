/*
Matthew Crump
ECE5710, Fall 2022
The Stupid Machine, a 1-Bit Processor
Tests for the OneBitProcessor
*/
`timescale 1 ns / 100 ps

// Macros
//`define ABS_FILEPATH "ur path here"

module OneBitProcessor_tb;

	reg clk;
	initial begin
		$display($time, " << Starting the Simulation");

		clk = 0;
		forever #5 clk = ~clk;
	end

	parameter INSTRUCTION_LENGTH = 13;
	parameter OUT_REGS = 7;
	parameter IN_REGS = 2;

	//  TEST 1:  ===============================================================================

	// inputs to the DUT
	reg reset1;
	reg enable1;
	reg [1:0] input_signals1;
	// outputs from the DUT
	wire [6:0] regs_out1;

	OneBitProcessor dut1 (
		.clk(clk),
		.reset(reset1),
		.en(enable1),
		.inReg(input_signals1),
		.outReg(regs_out1));

	// Vals for test1:
	reg[12:0] testInstr;
	integer i;
	reg testFailed;

	initial begin
		reset1 = 0;
		enable1 = 0;

		// Test 1.1: Test reset

		// Reset dut
		#10 reset1 = 1;
		#10 reset1 = 0;

		// Test that Reset worked
		// Program Conter:
		if (dut1.prog_counter == '0)
			$display("Test 1.1.1 passed");
		else 
			$display("WARNING: Test 1.1 Failed: prog_counter was %d", dut1.prog_counter);
		// Registers (that the unit controlls):
		if (dut1.outReg == '0)
			$display("Test 1.1.2 passed");
		else 
			$display("WARNING: Test 1.1.2 Failed: outReg was %b", dut1.prog_counter);	
		if (dut1.internal_regs == '0)
			$display("Test 1.1.3 passed");
		else 
			$display("WARNING: Test 1.1.3 Failed: internal_regs was %d", dut1.internal_regs);
		// Instruction Mem:
		testFailed = '0;
		for (i = 0; i < dut1.INSTRUCTION_MEM; i = i + 1) begin
			if (dut1.instructions[i] == '0)
				; // Need this form: if instructions is z or x then enters else
			else begin
				testFailed = '1;
				$display("WARNING: Test 1.1.4 failed. instructions[%d] was %b", i, dut1.instructions[i]);
			end
		end
		if (testFailed)
			$display("WARNING: Test 1.1.4 failed. See above.");
		else 
			$display("Test 1.1.4 passed");

		// Test 1.2: load an instruction:
		input_signals1[0] = 1;
		enable1 = 1;

		// Wait 13 periods so a full instruction is just 1s
		#130

		if (dut1.instructions[0] == 'b1111111111111)
			$display("Test 1.2.1 passed");
		else
			$display("WARNING: Test 1.2.1 Failed: slot contained %b", dut1.instructions[0]);

		input_signals1[0] = 0;
		// Same as before, but 0s this time
		#130

		if (dut1.instructions[1] == 'b0000000000000 && dut1.instructions[0] == 'b1111111111111)// not overwriting
			$display("Test 1.2.2 passed");
		else
			$display("WARNING: Test 1.2.2 Failed: slot0 contained %b, slot1 contained %b", dut1.instructions[0], dut1.instructions[1]);

		input_signals1[0] = 1;
		for(i = 0; i < 13; i = i + 1) begin // Now, alternate bits
			#10 input_signals1[0] = ~input_signals1[0];
		end	
		if (dut1.instructions[2] == 'b1010101010101)
			$display("Test 1.2.3 passed");
		else 
			$display("WARNING: Test 1.2.3 failed: slot2 contained %b", dut1.instructions[2]);

		input_signals1[0] = 0;
		for(i = 0; i < 13; i = i + 1) begin // And the other way
			#10 input_signals1[0] = ~input_signals1[0];
		end	
		if (dut1.instructions[3] == 'b0101010101010)
			$display("Test 1.2.4 passed");
		else 
			$display("WARNING: Test 1.2.4 failed: slot3 contained %b", dut1.instructions[3]);

		// something arbitrary
		input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#30 input_signals1[0] = 1;  // Stays on 0 for 3 clock cycles
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#50 input_signals1[0] = 0;
		#20;  // Stay on 0 for 2 clock cycles to round out instruction with 0s
		if (dut1.instructions[4] == 'b0011111010001)
			$display("Test 1.2.5 passed");
		else 
			$display("WARNING: Test 1.2.5 failed: slot4 contained %b", dut1.instructions[3]);

		// wait some time and then write, to make sure later addresses can also be written to
		input_signals1[0] = 1;
		#(130*250) input_signals1[0] = 0;  // Skipping 250 instructions puts us on location 254
		// Check that all locations in the meantime received 
		testFailed = 0;
		for (i = 5; i < 254; i = i + 1) begin
			if (dut1.instructions[i] == 'b1111111111111)
				; // do nothing. If above evaluates to z or x it will enter the else block
			else 
				testFailed = 1;
		end
		if (testFailed)
			$display("WARNING: Test 1.2.6 failed");
		else
			$display("Test 1.2.6 passed");

		// now test that we can write to a later address:
		#10 input_signals1[0] = 1;
		#30 input_signals1[0] = 0;  // Stays on 1 for 3 clock cycles
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#50 input_signals1[0] = 1;
		#20;  // Stay on 1 for 2 clock cycles to round out instruction with 0s
		if (dut1.instructions[255] == 'b1100000101110)
			$display("Test 1.2.7 passed");
		else 
			$display("WARNING: Test 1.2.7 failed: slot254 contained %b", dut1.instructions[254]);

		// Just in case, test that it can write to the last instruction location
		#(129890 - $time) input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#40 input_signals1[0] = 0;
		#30 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10;
		if (dut1.instructions[999] == 'b1010001111010)
			$display("Test 1.2.8 passed");
		else 
			$display("WARNING: Test 1.2.8 failed: slot999 contained %b", dut1.instructions[999]);


		// Test 1.3: Testing the Program Couner
		reset1 = 0;
		enable1 = 0;
		#10 reset1 = 1;
		#10 reset1 = 0;

		// Write instructions to iterate over:
		enable1 = 1;
		// 1101010101010: NAND internal Reg0 w/ itself into itself
		input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		// 1001100110011: NAND output Reg0 w/ itself into itself
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		// 1000100010100: NAND input reg0 w/ itself into output reg1
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		// 1010001000100: NAND output reg1 w/ itself into itself
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		#10 enable1 = 0;

		// check that prog_counter resets to 0
		if (dut1.prog_counter == 0)
			$display("Test 1.3.1 passed");
		else
			$display("ERROR: Test 1.3.1 failed: prog_counter was %d", dut1.prog_counter);

		#10;
		if (dut1.prog_counter == 1)  // Check that prog_counter properly increases
			$display("Test 1.3.2 passed");
		else
			$display("ERROR: Test 1.3.2 failed: prog_counter was %d", dut1.prog_counter);

		#10;
		if (dut1.prog_counter == 2)  // Check that prog_counter properly increases
			$display("Test 1.3.3 passed");
		else
			$display("ERROR: Test 1.3.3 failed: prog_counter was %d", dut1.prog_counter);

		#10;
		if (dut1.prog_counter == 3)  // Check that prog_counter properly increases
			$display("Test 1.3.4 passed");
		else
			$display("ERROR: Test 1.3.4 failed: prog_counter was %d", dut1.prog_counter);

		// Test 1.4: Test that NAND operations function correctly

		reset1 = 0;
		enable1 = 0;
		#10 reset1 = 1;
		#10 reset1 = 0;

		// Write instructions to iterate over:
		enable1 = 1;
		// 1101010101010: NAND internal Reg0 w/ itself into itself  (Test 1.4.1)
		input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		// twice: make sure invert works  (Test 1.4.2)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		// 1001100110011: NAND output Reg0 w/ itself into itself (Test 1.4.3)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		// Same as last (Test 1.4.4)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		// 1000100010100: NAND input reg0 w/ itself into output reg1 (Test 1.4.5)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		// Same (Test 1.4.6)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		// 1010001000100: NAND output reg1 w/ itself into itself (Test 1.4.7)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		// Same (Test 1.4.8)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 1 1010 0011 0101 : NAND internal0 and out0 into out2 (Test 1.4.9)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;

		// 1 0101 1010 1100 : NAND out2 and internal0 into internal2 (Test 1.4.10)
		#10 input_signals1[0] = 1;	
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 1 1100 0101 1111 : NAND internal2 and out2 into internal5 (Test 1.4.11)
		#10 input_signals1[0] = 1;	
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;

		// 1 0111 0010 1001 NAND out5 and input1 into out6 (Test 1.4.12)
		#10 input_signals1[0] = 1;	
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;

		// 1 0000 0000 1001 : NAND constant reg w/ itself into out6 (Test 1.4.13)
		#10 input_signals1[0] = 1;	
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;

		// 1 0000 1000 0110 : NAND constant reg w/ out5 into out3 (Test 1.4.14)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;

		// 1 1101 1101 0000 : Try "assigning" 1 to const reg
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 1 0000 0000 0110 : NAND constant reg w/ itself into out3, make sure still works (Test 1.4.15)
		#10 input_signals1[0] = 1;	
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;

		// 1 1101 0000 1110 : NAND internal3 (which should be 0) with const into internal4 (Test 1.4.16)
		#10 input_signals1[0] = 1;	
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;



		#10 enable1 = 0;
		#10; // Need to wait a cycle for 1st instruction to execute
		// 1st instruction: NAND internal Reg0 w/ itself into itself
		if (dut1.internal_regs[0] == 1) 
			$display("Test 1.4.1 passed");
		else
			$display("WARNING: Test 1.4.1 failed: internal_regs[0] was %b", dut1.internal_regs[0]);

		// invert again to make sure it goes both ways
		#10;
		if (dut1.internal_regs[0] == 0) 
			$display("Test 1.4.2 passed");
		else
			$display("WARNING: Test 1.4.2 failed: internal_regs[0] was %b", dut1.internal_regs[0]);

		// inverts out_regs[0], resulting in 1
		#10;
		if (regs_out1[0] == 1) 
			$display("Test 1.4.3 passed");
		else
			$display("WARNING: Test 1.4.3 failed: internal_regs[0] was %b", dut1.internal_regs[0]);

		// invert again to make sure it goes both ways
		#10;
		if (regs_out1[0] == 0) 
			$display("Test 1.4.4 passed");
		else
			$display("WARNING: Test 1.4.4 failed: internal_regs[0] was %b", dut1.internal_regs[0]);

		// inverts in_reg0 into out_reg[1]
		input_signals1[0] = 0;
		#10;
		if (regs_out1[1] == 1)
			$display("Test 1.4.5 passed");
		else
			$display("WARNING: Test 1.4.5 failed: regs_out[1] was %b", regs_out1[1]);

		// repeat above for 0
		input_signals1[0] = 1;
		#10;
		if (regs_out1[1] == 0)
			$display("Test 1.4.6 passed");
		else
			$display("WARNING: Test 1.4.6 failed: regs_out[1] was %b", regs_out1[1]);

		// inverts out_reg1 into itself 
		#10;
		if (regs_out1[1] == 1)
			$display("Test 1.4.7 passed");
		else
			$display("WARNING: Test 1.4.7 failed: regs_out[1] was %b", regs_out1[1]); 

		#10;
		if (regs_out1[1] == 0)
			$display("Test 1.4.8 passed");
		else
			$display("WARNING: Test 1.4.8 failed: regs_out[1] was %b", regs_out1[1]); 

		#10;
		if (regs_out1[2] == 1)
			$display("Test 1.4.9 passed");
		else
			$display("WARNING: Test 1.4.9 failed: regs_out[2] was %b", regs_out1[2]); 

		#10;
		if (dut1.internal_regs[2] == 1)
			$display("Test 1.4.10 passed");
		else
			$display("WARNING: Test 1.4.10 failed: intenal_regs[2] was %b", dut1.internal_regs[2]); 

		#10;
		if (regs_out1[5] == 0)
			$display("Test 1.4.11 passed");
		else
			$display("WARNING: Test 1.4.11 failed: regs_out[5] was %b", regs_out1[5]); 

		input_signals1[1] = 1;
		#10;
		if (regs_out1[6] == 1)
			$display("Test 1.4.12 passed");
		else
			$display("WARNING: Test 1.4.12 failed: regs_out[6] was %b", regs_out1[6]); 

		#10;
		if (regs_out1[6] == 0)
			$display("Test 1.4.13 passed");
		else
			$display("WARNING: Test 1.4.13 failed: regs_out[6] was %b", regs_out1[6]); 

		#10;
		if (regs_out1[3] == 1)
			$display("Test 1.4.14 passed");
		else
			$display("WARNING: Test 1.4.14 failed: regs_out[3] was %b", regs_out1[3]); 

		#10;  // The "assignment" to const reg
		#10;  // Trying to NAND const with itself
		if (regs_out1[3] == 0)
			$display("Test 1.4.15 passed");
		else
			$display("WARNING: Test 1.4.15 failed: regs_out[3] was %b", regs_out1[3]); 

		#10;
		if (dut1.internal_regs[4] == 1)
			$display("Test 1.4.16 passed");
		else
			$display("WARNING: Test 1.4.16 failed: internal_regs[4] was %b", dut1.internal_regs[4]);


		// Test 1.5: Branching statements
		reset1 = 0;
		enable1 = 0;
		#10 reset1 = 1;
		#10 reset1 = 0;

		// Write instructions to iterate over:
		enable1 = 1;
		// 0 0011 0 1111111 : Branch on out0, jump forward 127 spaces (Test 1.5.1, just checking prog_counter val)
		input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;

		// 1101010101010: NAND internal Reg0 w/ itself into itself (so we have a 1 val to use to check 1.5.1)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;

		// 0 1010 0 0000010 : Branch on internal0, jump forward 2 spaces (Test 1.5.2)
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;

		// 1 0101 0101 0011 : NAND internal0 w/ itself into out0, resulting in out0=0 if previous instruction (Test 1.5.2) failed
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;

		 // 1 0011 0011 0011 : NAND out0 w/ itself into itself: if Test 1.5.2 succeeds, out0=1 (Test 1.5.3)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;

		// 1 1100 1100 1100 : invert internal2
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 0 0010 0 0000011 : branch on in1, advance 3
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;

		// 0 1100 1 0000010 : branch on internal2 (which should now be true) and jump back 2 (which will set internal2 false again)
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;

		// 1 0000 0000 1100 :Set internal2 to 0 (if branch fails)
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 0 0010 0 0000000 : Test that the "stay still" branch works as intended (branch on in1, Test 1.5.7-1.5.9)
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 1 0100 0100 0100 : Set out1 to 1 after execution resumes
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 0 0001 1 0000000 : Test that the "stay still" branch works as intended (branch on in0, Test 1.5.10)
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		// 1 0100 0100 0100 : Set out1 to 0 after execution resumes
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 1;
		#10 input_signals1[0] = 0;
		#10 input_signals1[0] = 0;

		#10 enable1 = 0;
		#10; // Need to wait a cycle for 1st instruction to execute

		if (dut1.prog_counter == 1)
			$display("Test 1.5.1 passed.");
		else
			$display("WARNING: Test 1.5.1 failed: prog_counter was %d, not 1", dut1.prog_counter);

		#10; // Put positive val on internal0
		#10; // Branch on internal0, prog_counter should now be 4

		if (dut1.prog_counter == 4)
			$display("Test 1.5.2 passed.");
		else
			$display("WARNING: Test 1.5.2 failed: prog_counter was %d, not 4", dut1.prog_counter);

		#10; // out0 should be 1 if Test 1.5.2 suceeded
		if (regs_out1[0] == 1)
			$display("Test 1.5.3 passed.");
		else
			$display("WARNING: Test 1.5.3 failed: regs_out[0] was %b", regs_out1[0]);

		#10 input_signals1[1] = 0;  // invert internal2, so it's 1
		#10;   // in1 is 0, so this branch should not activate
		#10; // branch: go back 2 instructions, to invert internal2
		#10; // Should invert internal2 again back to 0
		if (dut1.prog_counter == 6)
			$display("Test 1.5.4 passed.");
		else
			$display("WARNING: Test 1.5.4 failed: prog_couner was %d", dut1.prog_counter);
		if (dut1.internal_regs[2] == 0)
			$display("Test 1.5.5 passed.");
		else
			$display("WARNING: Test 1.5.5 failed: internal_regs[2] was %b", dut1.internal_regs[2]);


		input_signals1[1] = 1;
		#10; // With in1 high, should now go forward 3
		if (dut1.prog_counter == 9)
			$display("Test 1.5.6 passed.");
		else
			$display("WARNING: Test 1.5.6 failed: prog_couner was %d", dut1.prog_counter);

		// input_signals1[1] is already 1, so should stay still
		#10;
		if (dut1.prog_counter == 9)
			$display("Test 1.5.7 passed.");
		else
			$display("WARNING: Test 1.5.7 failed: prog_couner was %d", dut1.prog_counter);	
		if (regs_out1[1] == 0)
			$display("Test 1.5.8 passed.");
		else
			$display("WARNING: Test 1.5.8 failed: regs_out1[1] was %b", regs_out1[1]);		

		#10;  // prog_counter should stay at 9 no matter how much time passes as long as in1 is 1
		if (dut1.prog_counter == 9)
			$display("Test 1.5.9 passed.");
		else
			$display("WARNING: Test 1.5.9 failed: prog_couner was %d", dut1.prog_counter);	
		if (regs_out1[1] == 0)
			$display("Test 1.5.10 passed.");
		else
			$display("WARNING: Test 1.5.10 failed: regs_out1[1] was %b", regs_out1[1]);	
		#100;	
		if (dut1.prog_counter == 9)
			$display("Test 1.5.11 passed.");
		else
			$display("WARNING: Test 1.5.11 failed: prog_couner was %d", dut1.prog_counter);
		if (regs_out1[1] == 0)
			$display("Test 1.5.12 passed.");
		else
			$display("WARNING: Test 1.5.12 failed: regs_out1[1] was %b", regs_out1[1]);		


		input_signals1[1] = 0;
		#10; // Now the counter should advance; 
		if (dut1.prog_counter == 10)
			$display("Test 1.5.11 passed.");
		else
			$display("WARNING: Test 1.5.11 failed: prog_couner was %d", dut1.prog_counter);
		#10;
		if (regs_out1[1] == 1)
			$display("Test 1.5.12 passed.");
		else
			$display("WARNING: Test 1.5.12 failed: regs_out1[1] was %b", regs_out1[1]);	

		input_signals1[0] = 1;
		//next instruction is same as last branch but on in0 (and "advances" 0 instead of regressing)
		#10;
		if (dut1.prog_counter == 11)
			$display("Test 1.5.13 passed.");
		else
			$display("WARNING: Test 1.5.13 failed: prog_couner was %d", dut1.prog_counter);	
		#10; // prog_counter should stay same as long as in0 is 1)
		if (dut1.prog_counter == 11)
			$display("Test 1.5.14 passed.");
		else
			$display("WARNING: Test 1.5.14 failed: prog_couner was %d", dut1.prog_counter);	
		if (regs_out1[1] == 1)
			$display("Test 1.5.15 passed");
		else
			$display("ERROR: Test 1.5.15 failed: regs_out[1] was %b", regs_out1[1]);

		#50;
		if (dut1.prog_counter == 11)
			$display("Test 1.5.16 passed.");
		else
			$display("WARNING: Test 1.5.16 failed: prog_couner was %d", dut1.prog_counter);
		if (regs_out1[1] == 1)
			$display("Test 1.5.17 passed");
		else
			$display("ERROR: Test 1.5.17 failed: regs_out[1] was %b", regs_out1[1]);	

		input_signals1[0] = 0; // Now the prog_counter should advance
		#10;
		if (dut1.prog_counter == 12)
			$display("Test 1.5.18 passed.");
		else
			$display("WARNING: Test 1.5.18 failed: prog_couner was %d", dut1.prog_counter);	
		#10;  // Last instruction: flip out1 back to 0
		if (regs_out1[1] == 0)
			$display("Test 1.5.19 passed");
		else
			$display("ERROR: Test 1.5.19 failed: regs_out[1] was %b", regs_out1[1]);	

		$display("Test 1 finished");
		// End of Test 1
	end

	// TEST 2: Run a simple program: shift register  ==============================================================
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

	// FileIO vars
	integer fd_test2;
	//reg[640*8:0] errorMessage;  // For debugging File I/O; see below
	integer lineNo; 
	reg[8*13:1] instructions2;
	parameter NO_INSTRUCTIONS_IN_SHIFT_REG = 16;
	reg[12:0] binrep[(NO_INSTRUCTIONS_IN_SHIFT_REG - 1):0];

	// genaral test vars
	integer i2, j2;  // for loop vars
	parameter test2_prog_length = 16;  // num of instructions in program for test2
	reg boolVal;

	initial begin
		// load instructions from file
		fd_test2 = $fopen(Absolute path to shift_reg.1bin, "r");

		// In future, using a reative file path and/or a macro would be better, but I couldn't get Vsim to cooperate
		//fd_test2 = $fopen(`ABS_FILEPATH);
		//fd_test2 = $fopen("./../Assembler/test.1bin");
		
		// For debugging:
		//$display("file handler: %d", fd_test2);
		//$ferror(fd_test2, errorMessage);
		//$display("%s", errorMessage);

		lineNo = 0;
		while (! $feof(fd_test2)) begin
			$fgets(instructions2, fd_test2);
 			// Every other line is a newline and zeros, and the last line is entirely zeros. Ignore these lines.
			if ((instructions2[8:1] != "\n") && (instructions2[8:1] != 'b00000000)) begin
				for (i2 = 0; i2 < 13; i2 = i2 + 1) begin
					//$display("%b %d", instructions2[((i2*8)+1)+:8], i2); // For debug: print current char in binary
					if (instructions2[((i2*8)+1)+:8] == 8'b00110001) begin  // "1" string/char in binary
						binrep[lineNo][i2] = 1;
					end else begin
						binrep[lineNo][i2] = 0;
					end  //if
				end  // for loop
				lineNo = lineNo + 1;
			end  // if not newline or blank
		end // while file not ended
		$fclose(fd_test2);

/*
		// For debug purposes: print out the bits in order
		$display("Contents of binrep:");
		for (i2 = 0; i2 < 6; i2 = i2 + 1) begin
			$display("%b", binrep[i2]);
			for (j2 = 12; j2 >= 0; j2 = j2 - 1) begin
				$display("%b", binrep[i2][j2]);  // This prints/returns the bits in the correct order
			end
		end
*/
		// Reset dut
		reset2 = 0;
		enable2 = 0;
		#10 reset2 = 1;
		#10 reset2 = 0;

		// Loading instructions into dut
		enable2 = 1;
		for (i2 = 0; i2 < test2_prog_length; i2 = i2 + 1) begin
			for (j2 = INSTRUCTION_LENGTH - 1; j2 >= 0; j2 = j2 - 1) begin //(j2 = 0; j2 < INSTRUCTION_LENGTH; j2 = j2 + 1) begin
				input_signals2[0] = binrep[i2][j2];
				#10;
			end
		end
		enable2 = 0;
		input_signals2[0] = 0;

		// execution of program begins
		// Should begin on instruction 0 waiting for IN1 to be low. Kep high for a few cycles to make sure it works
		input_signals2[1] = 1;
		#10;
		boolVal = '0;
		for (i2 = 0; i < OUT_REGS; i = i + 1) begin
			if (regs_out2[i] == 0)  // all out regs should be set to 0 following reset
				;// Do nothing; if if evals to x or z, will enter else block
			else
				boolVal = '1;
		end
		// Report if some of the out regs are not 0
		if (boolVal)
			$display("WARNING: Test 2.1 failed: not all out regs were initialized to 0");
		else 
			$display("Test 2.1 passed");

		boolVal = '0;
		#20;
		for (i2 = 0; i < OUT_REGS; i = i + 1) begin
			if (regs_out2[i] == 0)  // should still be zero since exec is paused w/ IN0 high
				;  // Do nothing. Having an else is tripped even if the condition evals to x
			else
				boolVal = '1;
		end
		if (boolVal)
			$display("WARNING: Test 2.2 failed: did not hold out regs at 0 (software problem?)");
		else 
			$display("Test 2.2 passed");

		// just one more time
		boolVal = '0;
		#10 input_signals2[0] = 0;
		for (i2 = 0; i < OUT_REGS; i = i + 1) begin
			if (regs_out2[i] == 0)  // should still be zero since exec is paused w/ IN0 high
				; // Do nothing. Having an else is tripped even if the condition evals to x
			else
				boolVal = '1;
		end
		if (boolVal)
			$display("WARNING: Test 2.3 failed: did not hold out regs at 0 (software problem?)");
		else 
			$display("Test 2.3 passed");


		#(10 * test2_prog_length);
		// NOW start shifting
		input_signals2[1] = 0;
		input_signals2[0] = 0;
		#(10 * test2_prog_length);
		boolVal = '0;
		for (i2 = 0; i < OUT_REGS; i = i + 1) begin
			if (regs_out2[i] == 0)  // Shifting, but in is 0, so all should still be 0
				; // Do nothing. Having an else is tripped even if the condition evals to x
			else
				boolVal = '1;
		end
		if (boolVal)
			$display("WARNING: Test 2.4 failed: 1st shift should still leave all out regs 0 (software problem?)");
		else 
			$display("Test 2.4 passed");

		input_signals2[0] = 1;
		#(10 * test2_prog_length);
		if (regs_out2[0] == 1)  // OUT0 should be high now
			$display("Test 2.5 passed");
		else
			$display("WARNING: Test 2.5 Failed: Out0 should be 1, was %b.", regs_out2[0]);
		boolVal = '0;
		for (i2 = 1; i < OUT_REGS; i = i + 1) begin 
			if (regs_out2[i] == 0) // All other OUTs should be low still
				; // Do nothing. Having an else is tripped even if the condition evals to x
			else
				boolVal = '1;
		end
		if (boolVal)
			$display("WARNING: Test 2.6 failed: 12nd shift should have last 6 regs 0 (software problem?)");
		else 
			$display("Test 2.6 passed");

		input_signals2[0] = 0;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0000010)
			$display("Test 2.7 passed");
		else
			$display("WARNING: Test 2.7 Failed");

		input_signals2[0] = 1;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0000101)
			$display("Test 2.8 passed");
		else
			$display("WARNING: Test 2.8 Failed");

		// leave at 1
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0001011)
			$display("Test 2.9 passed");
		else
			$display("WARNING: Test 2.9 Failed");

		// leave at 1
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0010111)  
			$display("Test 2.10 passed");
		else
			$display("WARNING: Test 2.10 Failed");

		// PAUSE: make sure it branches
		input_signals2[1] = 1;
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test 2.11 passed");
		else
			$display("WARNING: Test 2.11 Failed");
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test 2.12 passed");
		else
			$display("WARNING: Test 2.12 Failed");
		#20;
		if (regs_out2 == 'b0010111)
			$display("Test 2.13 passed");
		else
			$display("WARNING: Test 2.13 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0010111)
			$display("Test 2.14 passed");
		else
			$display("WARNING: Test 2.14 Failed");
		#400;
		if (regs_out2 == 'b0010111)
			$display("Test 2.15 passed");
		else
			$display("WARNING: Test 2.15 Failed");

		input_signals2[0] = 0;  // still paused
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test 2.16 passed");
		else
			$display("WARNING: Test 2.16 Failed");
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test 2.17 passed");
		else
			$display("WARNING: Test 2.17 Failed");
		#20;
		if (regs_out2 == 'b0010111)
			$display("Test 2.18 passed");
		else
			$display("WARNING: Test 2.18 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0010111)
			$display("Test 2.19 passed");
		else
			$display("WARNING: Test 2.19 Failed");
		#400;
		if (regs_out2 == 'b0010111)
			$display("Test 2.20 passed");
		else
			$display("WARNING: Test 2.20 Failed");

		// resume shifting
		input_signals2[1] = 0;

		// back to 0
		input_signals2[0] = 0;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0101110)
			$display("Test 2.21 passed");
		else
			$display("WARNING: Test 2.21 Failed");

		// back to 1
		input_signals2[0] = 1;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1011101)
			$display("Test 2.22 passed");
		else
			$display("WARNING: Test 2.22 Failed");

		// hold at 1
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0111011)
			$display("Test 2.23 passed");
		else
			$display("WARNING: Test 2.23 Failed");

		// back to 0
		input_signals2[0] = 0;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1110110)
			$display("Test 2.24 passed");
		else
			$display("WARNING: Test 2.24 Failed");

		// back to 1
		input_signals2[0] = 1;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1101101)
			$display("Test 2.25 passed");
		else
			$display("WARNING: Test 2.25 Failed");

		// hold 1 for remaining test
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1011011)
			$display("Test 2.26 passed");
		else
			$display("WARNING: Test 2.26 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0110111)
			$display("Test 2.27 passed");
		else
			$display("WARNING: Test 2.27 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1101111)
			$display("Test 2.28 passed");
		else
			$display("WARNING: Test 2.28 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1011111)
			$display("Test 2.29 passed");
		else
			$display("WARNING: Test 2.29 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0111111)
			$display("Test 2.30 passed");
		else
			$display("WARNING: Test 2.30 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1111111)
			$display("Test 2.31 passed");
		else
			$display("WARNING: Test 2.31 Failed");
		if (regs_out2 == 'b1111111)
			$display("Test 2.32 passed");
		else
			$display("WARNING: Test 2.32 Failed");

		$display("Test 2 finished");
		// End of Test 2 (shift_reg.1bin)
	end
endmodule
	