module mem(
    input wire                  rst,

    // Data from exe_mem register
    input wire[`RegAddrBus]     wd_i,
    input wire[`RegBus]         wdata_i,
    input wire                  wreg_i

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
        end else begin
            wd_o        <=      wd_i;
            wdata_o     <=      wdata_i;
            wreg_o      <=      wreg_i;
        end
    end

endmodule
