`include "../../defines/defines.v"

module id_ex(
    input wire              clk,
    input wire              rst,

    // Data from decode stage
    input wire[`AluOpBus]    id_aluop,
    input wire[`AluSelBus]   id_alusel,
    input wire[`RegBus]      id_reg1,
    input wire[`RegBus]      id_reg2,
    input wire[`RegAddrBus]  id_wd,
    input wire               id_wreg,

    // Data send to Execute stage
    output reg[`AluOpBus]    ex_aluop,
    output reg[`AluSelBus]   ex_alusel,
    output reg[`RegBus]      ex_reg1,
    output reg[`RegBus]      ex_reg2,
    output reg[`RegAddrBus]  ex_wd,
    output reg               ex_wreg
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_aluop    <=    `EXE_NOP_OP;
            ex_alusel   <=    `EXE_RES_NOP;
            ex_reg1     <=    `ZeroWord;
            ex_reg2     <=    `ZeroWord;
            ex_wd       <=    `NOPRegAddr;
            ex_wreg     <=    `WriteDisable;
        end else begin
            ex_aluop    <=    `EXE_OR_OP;
            ex_alusel   <=    `EXE_RES_LOGIC;
            ex_reg1     <=    id_reg1;
            ex_reg2     <=    id_reg2;
            ex_wd       <=    id_wd;
            ex_wreg     <=    id_wreg;
        end
    end
endmodule
