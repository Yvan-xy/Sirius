`ifndef DEFINE_V
`define DEFINE_V

`define RstEnable       1'b1
`define RstDisable      1'b0
`define ZeroWord        32'h00000000
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define AluOpBus        7:0
`define AluSelBus       2:0
`define InstValid       1'b0
`define InstInvalid     1'b1
`define True_v          1'b1
`define False_v         1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0

/****   Instructions ****/
// func_code
`define EXE_ORI              6'b001101
`define EXE_NOP              6'b000000
`define EXE_AND              6'b100100
`define EXE_OR               6'b100101   
`define EXE_XOR              6'b100110
`define EXE_NOR              6'b100111
`define EXE_ANDI             6'b001100
`define EXE_XORI             6'b001110
`define EXE_LUI              6'b001111

`define EXE_SLL              6'b000000
`define EXE_SLLV             6'b000100
`define EXE_SRL              6'b000010
`define EXE_SRLV             6'b000110
`define EXE_SRA              6'b000011
`define EXE_SRAV             6'b000111

`define EXE_MOVZ             6'b001010
`define EXE_MOVN             6'b001011
`define EXE_MFHI             6'b010000
`define EXE_MTHI             6'b010001
`define EXE_MFLO             6'b010010
`define EXE_MTLO             6'b010011

`define EXE_SLT              6'b101010
`define EXE_SLTU             6'b101011
`define EXE_SLTI             6'b001010
`define EXE_SLTIU            6'b001011
`define EXE_ADD              6'b100000
`define EXE_ADDU             6'b100001
`define EXE_SUB              6'b100010
`define EXE_SUBU             6'b100011
`define EXE_ADDI             6'b001000
`define EXE_ADDIU            6'b001001
`define EXE_CLZ              6'b100000
`define EXE_CLO              6'b100001

`define EXE_MULT             6'b011000
`define EXE_MULTU            6'b011001
`define EXE_MUL              6'b000010

`define EXE_SYNC             6'b001111
`define EXE_PREF             6'b110011

`define EXE_SPECIAL_INST     6'b000000 
`define EXE_REGIMM_INST      6'b000001
`define EXE_SPECIAL2_INST    6'b011100

// AluOp
`define EXE_OR_OP       8'b00100101
`define EXE_AND_OP      8'b00100100
`define EXE_XOR_OP      8'b00100110
`define EXE_NOR_OP      8'b00100111

`define EXE_SLL_OP      8'b01111100
`define EXE_SRL_OP      8'b00000010
`define EXE_SRA_OP      8'b00000011


`define EXE_MOVZ_OP     8'b00001010
`define EXE_MOVN_OP     8'b00001011
`define EXE_MFHI_OP     8'b00010000
`define EXE_MFLO_OP     8'b00010010
`define EXE_MTHI_OP     8'b00010001
`define EXE_MTLO_OP     8'b00010011

`define EXE_ADD_OP      8'b00100000
`define EXE_ADDI_OP     8'b01011001
`define EXE_ADDU_OP     8'b00100001
`define EXE_ADDIU_OP    8'b01010110
`define EXE_SUB_OP      8'b00100010
`define EXE_SUBU_OP     8'b00100011
`define EXE_SLT_OP      8'b00101010
`define EXE_SLTU_OP     8'b00101011
`define EXE_CLZ_OP      8'b10110000
`define EXE_CLO_OP      8'b10110001
`define EXE_MULT_OP     8'b00011000
`define EXE_MULTU_OP    8'b00011001
`define EXE_MUL_OP      8'b10101001


`define EXE_NOP_OP      8'b00000000

// AluSel
`define EXE_RES_LOGIC           3'b001
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_MOVE            3'b011
`define EXE_RES_ARITHMETIC      3'b100
`define EXE_RES_MUL             3'b101
`define EXE_RES_JUMP_BRANCH     3'b110
`define EXE_RES_LOAD_STORE      3'b111
`define EXE_RES_NOP             3'b000

/****   Marcos About ROM ****/
`define InstAddrBus     31:0    // Width of Address Bus
`define InstBus         31:0    // Width of Data Bus
`define InstMemNum      131071  // Real size of ROM -- 128KB
`define InstMemNumLog2  17      // Real Width of Address Bus

/****   Marcos About Regfile ****/
`define RegAddrBus      4:0     // Width of address Bus of Regfile
`define RegBus          31:0    // Width of data Bus of Regfile
`define RegWidth        32      // Width of universal register
`define DoubleRegWidth  64      // Double size of RegWidth
`define DoubleRegBus    63:0    // Double size of RegBus
`define RegNum          32      // Numbers of universal registers
`define RegNumLog2      5       // Width of Address Register
`define NOPRegAddr      5'b00000

`endif
