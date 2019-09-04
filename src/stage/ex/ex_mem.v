`include "../../defines/defines.v"

module ex_mem(
    input wire                  clk,
    input wire                  rst,

    //Data from execute stage
    input wire[`RegAddrBus]     ex_wd,
    input wire[`RegBus]         ex_wdata,
    input wire                  ex_wreg,

    //Data send to memory stage
    output reg[`RegAddrBus]     mem_wd,
    output reg[`RegBus]         mem_wdata,
    output reg                  mem_wreg
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            mem_wd      <=      `ZeroWord;
            mem_wreg    <=      `WriteDisable;
            mem_wdata   <=      `ZeroWord;
        end else begin
            mem_wd      <=      ex_wd;
            mem_wdata   <=      ex_wdata;
            mem_wreg    <=      ex_wreg;
        end
    end

endmodule
