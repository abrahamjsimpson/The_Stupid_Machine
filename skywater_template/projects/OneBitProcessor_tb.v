/*
Matthew Crump
ECE5710, Fall 2022
The Stupid Machine, a 1-Bit Processor
Test Bench
Tests for the OneBitProcessor and associated sub-modules
*/
`timescale 1 ns / 100 ps

// Macros
//`define ABS_FILEPATH "ur path here"

module OneBitProcessor_tb;

	reg clk;
	initial begin
		$display($time, " << Starting the Simulation");
/*
		$display("1 as bin:");
		$display("%b", "1");  // 00110001
		$display("0 as bin:");
		$display("%b", "0");  //00110000
		$display("newline as bin:");
		$display("%b", "\n");  //00001010
*/
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
	//reg[640*8:0] errorMessage;
	integer lineNo; 
	reg[8*13:1] instructions2;
	reg[12:0] binrep[5:0];

	// genaral test vars
	integer i2, j2;  // for loop vars
	parameter test2_prog_length = 16;  // num of instructions in program for test2
	reg boolVal;

	initial begin
		lineNo = 0;
		// load instructions from file
		//fd_test2 = $fopen(`ABS_FILEPATH);
		//fd_test2 = $fopen("./../Assembler/test.1bin");
		fd_test2 = $fopen(Absolute path here, "r");
		
		// For debugging:
		//$display("file handler: %d", fd_test2);
		//$ferror(fd_test2, errorMessage);
		//$display("%s", errorMessage);

		while (! $feof(fd_test2)) begin
			$fgets(instructions2, fd_test2);
			if ((instructions2[8:1] != "\n") && (instructions2[8:1] != 'b00000000)) begin  // Every other line is a newline and zeros, and the last line is entirely zeros. Ignore these lines
				//$display("%s", instructions2);
				//$display("%d", lineNo);
				for (i2 = 0; i2 < 13; i2 = i2 + 1) begin
					//$display("%b %d", instructions2[((i2*8)+1)+:8], i2); // print current char in binary
					if (instructions2[((i2*8)+1)+:8] == 8'b00110001) begin  // "1" string in binary
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
		#10 reset2 = 1;
		#10 reset2 = 0;

		// Loading instructions into dut
		enable2 = 1;
		for (i2 = 0; i2 < test2_prog_length; i2 = i2 + 1) begin
			for (j2 = (INSTRUCTION_LENGTH - 1); j2 >= 0; j2 = j2 - 1) begin
				#10 input_signals2[0] = binrep[i2][j2];
			end
		end
		enable2 = 0;
		input_signals2[0] = 0;

		// execution of program begins
		// Should begin on instruction 0 waiting for IN1 to be low. Kep high for a few cycles to make sure it works
		input_signals2[1] = 1;

		boolVal = '0;
		for (i2 = 0; i < OUT_REGS; i = i + 1) begin
			if (regs_out2[i] == 0)  // all out regs should be set to 0 following reset
				;//$display("Test passed: regs_out2[%d] is 0", i);
			else
				boolVal = '1; //$display("WARNING: Test 2 Failed some out regs were not initially 0");
		end
		// Report if some of the out regs are not 0
		if (boolVal)
			$display("WARNING: Test 2.1 failed: not all out regs were initialized to 0");
		else 
			$display("Test 2.1 passed");

		boolVal = '0;
		#20;
		$display("%b", dut2.prog_counter);  // after any amount of time passes after reset, prog_couter is unknown (xs)
		#10 input_signals2[0] = 1;
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
			$display("WARNING: Test 2.5 failed: 12nd shift should have last 6 regs 0 (software problem?)");
		else 
			$display("Test 2.5 passed");

		input_signals2[0] = 0;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0000010)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		input_signals2[0] = 1;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0000101)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// leave at 1
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0001011)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// leave at 1
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// PAUSE: make sure it branches
		input_signals2[1] = 1;
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#20;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#400;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		input_signals2[0] = 0;  // still paused
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#10;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#20;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#400;
		if (regs_out2 == 'b0010111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// resume shifting
		input_signals2[1] = 0;

		// back to 0
		input_signals2[0] = 0;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0101110)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// back to 1
		input_signals2[0] = 1;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1011101)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// hold at 1
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0111011)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// back to 0
		input_signals2[0] = 0;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1110110)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// back to 1
		input_signals2[0] = 1;
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1101101)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		// hold 1 for ramaining test
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1011011)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0110111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1101111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1011111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b0111111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		#(10 * test2_prog_length);
		if (regs_out2 == 'b1111111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");
		if (regs_out2 == 'b1111111)
			$display("Test passed");
		else
			$display("WARNING: Test 2 Failed");

		$display("Test 2 finished");

	end


endmodule
	