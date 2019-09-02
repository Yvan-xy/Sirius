module id(
    input   wire                    rst,
    input   wire [`InstAddrBus]     pc_i,
    input   wire [`InstBus]         inst_i,

    
    input   wire [`RegBus]          reg1_data_i,
    input   wire [`RegBus]          reg2_data_i,


    output  wire    reg1_read_o,
    output  wire    reg2_read_o,

    output  wire [`RegAddrBus]      aluop_o,
    output  wire [`RegAddrBus]      alusel_o,
);
