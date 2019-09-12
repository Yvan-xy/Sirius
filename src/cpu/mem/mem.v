`include "../../defines/defines.v"

module mem(
    input wire                  rst,

    // Data from exe_mem register
    input wire[`RegAddrBus]     wd_i,
    input wire[`RegBus]         wdata_i,
    input wire                  wreg_i,

    // HILO data from EX stage
    input wire[`RegBus]         hi_i,
    input wire[`RegBus]         lo_i,
    input wire                  whilo_i,

    // HILO data send to WriteBack stage
    output reg[`RegBus]         hi_o,
    output reg[`RegBus]         lo_o,
    output reg                  whilo_o,

    // Result of memory stage
    output reg[`RegAddrBus]     wd_o,
    output reg[`RegBus]         wdata_o,
    output reg                  wreg_o
);

    always @ (*) begin
        if(rst == `RstEnable) begin
            wd_o        <=      `NOPRegAddr;
            wdata_o     <=      `ZeroWord;
            wreg_o      <=      `WriteDisable;
            hi_o        <=      `ZeroWord;
            lo_o        <=      `ZeroWord;
            whilo_o     <=      `WriteDisable;
        end else begin
            wd_o        <=      wd_i;
            wdata_o     <=      wdata_i;
            wreg_o      <=      wreg_i;
            hi_o        <=      hi_i;
            lo_o        <=      lo_i;
            whilo_o     <=      whilo_i;
        end
    end

endmodule
