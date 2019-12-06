`include "defines.v"

module mem_wb (
    input wire                  clk,
    input wire                  rst,

    // Result of memory stage
    input wire[`RegAddrBus]     mem_wd,
    input wire[`RegBus]         mem_wdata,
    input wire                  mem_wreg,

    // HILO data from MEMORY stage
    input wire[`RegBus]         mem_hi,
    input wire[`RegBus]         mem_lo,
    input wire                  mem_whilo,

    // Signal from CTRL
    input wire[5:0]             stall,

    // HILO data send to WriteBack stage
    output reg[`RegBus]         wb_hi,
    output reg[`RegBus]         wb_lo,
    output reg                  wb_whilo,

    // Data send to write back stage
    output reg[`RegAddrBus]     wb_wd,
    output reg[`RegBus]         wb_wdata,
    output reg                  wb_wreg
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            wb_wd       <=      `NOPRegAddr;
            wb_wdata    <=      `ZeroWord;
            wb_wreg     <=      `WriteDisable;
            wb_hi       <=      `ZeroWord;
            wb_lo       <=      `ZeroWord;
            wb_whilo    <=      `WriteDisable;
        end else if(stall[4] == `Stop && stall[5] == `NoStop) begin
            wb_wd       <=      `NOPRegAddr;
            wb_wdata    <=      `ZeroWord;
            wb_wreg     <=      `WriteDisable;
            wb_hi       <=      `ZeroWord;
            wb_lo       <=      `ZeroWord;
            wb_whilo    <=      `WriteDisable;
        end else if(stall[4] == `NoStop) begin
            wb_wd       <=      mem_wd;
            wb_wdata    <=      mem_wdata;
            wb_wreg     <=      mem_wreg;
            wb_hi       <=      mem_hi;
            wb_lo       <=      mem_lo;
            wb_whilo    <=      mem_whilo;
        end
    end
    
endmodule
