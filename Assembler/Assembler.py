# Assembler for The Stupid Machine, a 1-Bit Processor
# by Matthew Crump
# The custom instruction set for this processor supports two formats for the two operations that the processor executes:
# NAND:
# 1: true
# 2-5: source register 1
# 6-9: source register 2
# 10-13: destination register
# Branch on True:
# 1: false
# 2-5: source register (if true, branch/jump; if false, continue to next instruction)
# 6: False for advance p.c., true for regress
# 7-13: Number of instructions to “jump” over (this number is added or subtracted from the p.c. based on bit 6)

# Register Mapping: There are 16 registers:
# 0000: High    Constant-held at logic '1' (Read-Only)
# 0001: In0     Input Register 0 (Read-Only)
# 0010: In1     Input Register 1 (Read-Only)
# 0011: Out0    Output Register 0
# 0100: Out1    Output Register 1
# 0101: Out2    Output Register 2
# 0110: Out3    Output Register 3
# 0111: Out4    Output Register 4
# 1000: Out5    Output Register 5
# 1001: Out6    Output Register 6
# 1010: Reg0    Internal Register 0   
# 1011: Reg1    Internal Register 1  
# 1100: Reg2    Internal Register 2   
# 1101: Reg3    Internal Register 3   
# 1110: Reg4    Internal Register 4   
# 1111: Reg5    Internal Register 5   
#
# For Branching number:
# Number shall begin with either a + (to advance p.c.) or a - (to regress). There shall be a space between the sign (+ or -) and the number.


import sys;

ASSEMBLY_SUFFIX = 'asm';
BIN_SUFFIX = '1bin';

# Convert register name to 4-bit reigster address.
def regNameToAddr(name):               
    shift = 0;
    # if name.lower()[0] == 'h':  # Constant
        # shift = 0;
    if name.lower()[0] == 'i':  # Input Regs
        shift = 1;
    elif name.lower()[0] == 'o':  # Output Regs
        shift = 3;
    elif name.lower()[0] == 'r':  # Internal Regs
        shift = 10;
    else:  # Stopgap solution for referring to constant FIXME
        return '0000';        
    return "{0:b}".format(int(name.rstrip()[-1]) + shift).zfill(4);

# Convert array of assembly tokens (as strings) into the corresponding binary instruction
def tokensToBin(tokens):
    retVal = "";
    if tokens[0].lower()[0] == 'n':   # if this is a NAND instruction:
        retVal += '1'; # first bit is a '1' for NAND
        for reg in range(1,4): # Should be three more tokens, for the three registers
            retVal += regNameToAddr(tokens[reg]);
    elif tokens[0].lower()[0] == 'b':  # for a branch:
        retVal += '0'; # first bit is a '0' for branch
        retVal += regNameToAddr(tokens[1]);  # convert Reg to bin address
        retVal += ('0' if (tokens[2][0] == '+') else '1');  # + for advance pc, - for regress
        retVal += "{0:b}".format(int(tokens[3])).zfill(7);
        
    return retVal;
        
    
#   ------BEGINNING OF MAIN----------    
# retrieve filename as a command line argument
readFileName = sys.argv[1];
# prepare name for bin file:
writeFileName = readFileName.rsplit( ".", 2 )[ 0 ] + "." + BIN_SUFFIX;

print("Converting " + sys.argv[1] + ' to ' + writeFileName);

#lineCount = 1;  # for error reporting; start on line 1
## read from assssembly file, convert to bin, and write to bin file line by line/instruction by instruction. Closes files when done. 
with open(readFileName, 'r') as asmblrFile, open(writeFileName, 'w') as binFile:  # opens both files
    # Iterate over all of the lines in the file
    for line in asmblrFile:
        tokens = line.split(' ');
        #print(tokensToBin(tokens));
        binFile.write(tokensToBin(tokens) + '\n');
        



