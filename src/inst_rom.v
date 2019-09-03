module inst_rom(
    input wire                  ce,
    input wire[`InstAddrBus]    addr,
    output reg[`InstBus]        inst
);
    
    // Define an inst array
    reg[`InstBus] inst_mem[0:`InstMemNum - 1];

    // Use the file "inst_rom.data" to init the inst_rom
    initial $readmemh ("inst_rom.data", inst_mem);

    always @ (*) begin
        if(ce == `ChipDisable) begin
            inst    <=    `ZeroWord;
        end else begin
            inst    <=    inst_mem[addr[`InstMemNumLog2 + 1:2]];    // addr[`InstMemNumLog2+1:2] => addr/4
        end
    end

endmodule
