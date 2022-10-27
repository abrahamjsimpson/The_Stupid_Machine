NAND in0 in1 out4
NAND in1 out4 reg2
BRANCH reg2 - 2
NAND reg2 in1 out4
BRANCH out4 - 4
NAND reg2 high reg1