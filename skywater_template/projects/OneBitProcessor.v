
module OneBitProcessor
	(input clk,
	input reset,
	input en,
	input [1:0] inReg,
	output reg [6:0] outReg);

	parameter INSTRUCTION_LENGTH = 13;  // # of bits in an instruction
	parameter INSTRUCTION_MEM = 1000; // # of instructions that can be stored in the processor's instruciton memory
	parameter PROG_COUNTER_LENGTH = 10;  // # of bits in program counter

	reg [(INSTRUCTION_LENGTH - 1):0] instructions [(INSTRUCTION_MEM - 1):0]; // instruction memory

	// items for loading instructions
	reg [(PROG_COUNTER_LENGTH - 1):0] load_instruction_counter;
	reg [(INSTRUCTION_LENGTH - 1):0] load_bit_counter;

	parameter JUMP_BITS = 7;

	parameter CONST_REG = 'b1;  // Literal reg is held at high/1
	parameter NUM_INPUT_REGS = 2;
	parameter NUM_OUT_REGS = 7;
	parameter NUM_INTERNAL_REGS = 6;
	parameter REG_ADDR_LENGTH = 4; // # of bits used in addressing processor's registers (16 total regs, so 4 bits)

	reg [(PROG_COUNTER_LENGTH - 1):0] prog_counter;
	reg [(NUM_INTERNAL_REGS - 1):0] internal_regs;
	
	// wires
	wire [(PROG_COUNTER_LENGTH - 1):0] prog_count_return, prog_count_out;
	wire [(REG_ADDR_LENGTH - 1):0] reg_1_addr, reg_2_addr, reg_3_addr, inst_mid, inst_bottom;
	wire [(JUMP_BITS - 1):0] jump, operand;
	wire ctrl_bit, nand_out, bit_6, adder_ctrl;
	reg data_1, data_2;

	// muxes:
	// two muxes that have ctrl_bit as sel line:
	assign reg_2_addr = ctrl_bit ? inst_mid : {(REG_ADDR_LENGTH){1'bz}};
	assign reg_3_addr = ctrl_bit ? inst_bottom : {(REG_ADDR_LENGTH){1'bz}};
	assign jump[2:0] = ctrl_bit ? {(3){1'bz}} : inst_mid[3:1];
	assign jump[6:3] = ctrl_bit ? {(4){1'bz}} : inst_bottom;
	assign bit_6 = ctrl_bit ? 'bz : inst_mid[0];
	// two muxes that feed into the program counter adder:
	assign operand = (!ctrl_bit && data_1) ? jump : 'b0000001;

	// determining add/subtract for program counter:
	assign adder_ctrl = (!ctrl_bit && bit_6);

	// NAND for registers:
	nand (nand_out, data_1, data_2);

	// program counter adder/subtractor: add on 0, subtract on 1
	assign prog_count_return = adder_ctrl ? (prog_count_out - operand) : (prog_count_out + operand);

	//updating program counter
	assign prog_count_out = prog_counter;
	always @ (posedge clk) begin
		if (reset) begin
			prog_counter = 0;
		end else  begin 
			if (!en) begin
				prog_counter = prog_count_return;
			end
		end
	end

	// Instruction fetch
	assign ctrl_bit = instructions[prog_count_out][0]; // bit 0 of the prog_count_out-th instruction
	assign reg_1_addr = instructions[prog_count_out][4:1];
	assign inst_mid = instructions[prog_count_out][8:5];
	assign inst_bottom = instructions[prog_count_out][12:9];

	// read regs:
	always @ * begin  // Infers a mux with constant assignment: see https://electronics.stackexchange.com/questions/240012/case-statement-without-always
		case (reg_1_addr)
			'b0000 : data_1 = CONST_REG;  // 0000 is the constant value, 1.
			'b0001 : data_1 = inReg[0];
			'b0010 : data_1 = inReg[1];
			'b0011 : data_1 = outReg[0];
			'b0100 : data_1 = outReg[1];
			'b0101 : data_1 = outReg[2];
			'b0110 : data_1 = outReg[3];
			'b0111 : data_1 = outReg[4];
			'b1000 : data_1 = outReg[5];
			'b1001 : data_1 = outReg[6];
			'b1010 : data_1 = internal_regs[0];
			'b1011 : data_1 = internal_regs[1];
			'b1100 : data_1 = internal_regs[2];
			'b1101 : data_1 = internal_regs[3];
			'b1110 : data_1 = internal_regs[4];
			'b1111 : data_1 = internal_regs[5];
		endcase

		case (reg_2_addr)
			'b0000 : data_2 = CONST_REG;  // 0000 is the constant value, 1.
			'b0001 : data_2 = inReg[0];
			'b0010 : data_2 = inReg[1];
			'b0011 : data_2 = outReg[0];
			'b0100 : data_2 = outReg[1];
			'b0101 : data_2 = outReg[2];
			'b0110 : data_2 = outReg[3];
			'b0111 : data_2 = outReg[4];
			'b1000 : data_2 = outReg[5];
			'b1001 : data_2 = outReg[6];
			'b1010 : data_2 = internal_regs[0];
			'b1011 : data_2 = internal_regs[1];
			'b1100 : data_2 = internal_regs[2];
			'b1101 : data_2 = internal_regs[3];
			'b1110 : data_2 = internal_regs[4];
			'b1111 : data_2 = internal_regs[5];
		endcase
	end

	// write regs:
	integer i;
	always @ (posedge clk) begin
		if (reset) begin
			// reset all registers
			for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin
				outReg[i] = 'b0;
			end
			for (i = 0; i < NUM_INTERNAL_REGS; i = i + 1) begin
				internal_regs[i] = 'b0;
			end
		end else begin
			if (ctrl_bit && !en) begin  // only enanle writing on NAND instructions, and disable when writing instructions to memory
				case (reg_3_addr)
					//  Note that writing to 'b0000 (constant reg), 'b0001, and 'b0010 (in regs) is forbidden
					'b0011 : outReg[0] = nand_out;
					'b0100 : outReg[1] = nand_out;
					'b0101 : outReg[2] = nand_out;
					'b0110 : outReg[3] = nand_out;
					'b0111 : outReg[4] = nand_out;
					'b1000 : outReg[5] = nand_out;
					'b1001 : outReg[6] = nand_out;
					'b1010 : internal_regs[0] = nand_out;
					'b1011 : internal_regs[1] = nand_out;
					'b1100 : internal_regs[2] = nand_out;
					'b1101 : internal_regs[3] = nand_out;
					'b1110 : internal_regs[4] = nand_out;
					'b1111 : internal_regs[5] = nand_out;
				endcase
			end  // end if (ctrl_bit)
		end  // end else
	end  // end always

	// reset loading counters when en is set high
	always @ (posedge en) begin
		load_instruction_counter = '0;
		load_bit_counter = '0;
	end 
	// write to instruction memory:
	always @ (posedge clk) begin
		if (reset) begin
			for (i = 0; i < INSTRUCTION_MEM; i = i + 1) begin
				instructions[i] = 'b0000000000000;
			end
		end else begin
			if (en) begin
				instructions[load_instruction_counter][load_bit_counter] = inReg[0];
				load_bit_counter = load_bit_counter + 1;
				if (load_bit_counter >= INSTRUCTION_LENGTH) begin
					load_bit_counter = '0;
					load_instruction_counter = load_instruction_counter + 1;
				end
			end
		end // end else
	end

endmodule
	 