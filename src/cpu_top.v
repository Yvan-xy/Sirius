`include "./defines/defines.v"
module cpu_top(
    input wire      clk,
    input wire      rst
);

    // Connect INST_ROM
    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire                rom_ce;

    // Instantiate Sirius
    Sirius Sirius(
         .clk(clk),
         .rst(rst),

         .rom_data_i(inst),
         .rom_addr_o(inst_addr),
         .rom_ce_o(rom_ce)
    );

    // Instantiate INST_ROM
    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );

endmodule
