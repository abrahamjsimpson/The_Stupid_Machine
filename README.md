# The_Stupid_Machine
A 1-bit Processor
# By: Matthew Crump

High Level Description:
	Many embedded applications call for processors with a small footprint. My project is to design and implement a 1-bit processor that has a minimal footprint. It will have no memory storage besides the instruction memory and 16 1-bit registers. Besides reset and the associated loading of a new set of instructions, it will only implement two operations: branch on a given register being true, and NAND of two registers, storing the result in a third register. NAND is functionally complete, meaning that all other logical processes can be executed, given enough time. It will rely on an external clock and take input and output directly from the registers: two register will be reserved for reading the input on the pin (writing to this pin will be forbidden), and 7 output pins will be set to the current value of corresponding registers.

The custom instruction set for this processor supports two formats for the two operations that the processor executes:
NAND:
1: 	true

2-5: 	source register 1

6-9:	source register 2
10-13:	destination register
Branch on True:
1: 	false
2-5:	source register (if true, branch/jump; if false, continue to next instruction)
6:	False for advance p.c., true for regress
7-13:	Number of instructions to “jump” over (this number is added or subtracted from the p.c. based on bit 6)

Testing:
	The Verilog code will be rigorously tested using Vsim. For unit testing, the different blocks in the diagram will be tested individually, as will the functionality for reset and for loading new instructions. For integration testing, a few small programs will be written in assembly, possibly using a custom assembler, to use in the test bed to test the processor’s functionality. Verilog includes functions to read data from a file, so lengthy programs can be written using an external program and then imported into the testbed.
The module will use the following pins:
In: 	reg0/read instruction bit
In:	reg1
Out:	reg2
Out:	reg3 
Out:	reg4 
Out:	reg5 
Out:	reg6 
Out:	reg7 
Out:	reg8
In:	clock
In:	synchronous reset
In:	Enable write to Instruction Memory
(12 signal pins, plus two for voltage supply and ground, for a total of 14 pins)
On the rising edge of the clock when reset is asserted, all registers and all instruction memory positions are reset to 0. When enable write is asserted, on each clock edge the value of reg0 is read into instruction memory, beginning at instruction 0, position 0 and proceeding across each bit of each instruction in order until enable write is deasserted, at which point execution of the program begins.

