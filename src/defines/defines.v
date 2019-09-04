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
`define EXE_ORI     6'b001101
`define EXE_NOP     5'b000000


//AluOp
`define EXE_OR_OP       8'b00100101
`define EXE_NOP_OP      8'b00000000

//AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_NOP     3'b000

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

