# Assembler for The Stupid MAchine, a 1-Bit Processor
import sys;

print("Running");

# retrieve filename as a command line argument
filename = sys.argv[1];
#print(filename);
#Open file as a file object
asmblrFile = open(filename, 'r');

# Iterate over all of the lines in the file
for line in asmblrFile:
    print(line)

# Close file
asmblrFile.close();

