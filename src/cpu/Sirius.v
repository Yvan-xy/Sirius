`include "../defines/defines.v"
module Sirius(
    input wire              clk,
    input wire              rst,

    input wire[`RegBus]     rom_data_i,     // fetched instruction
    output wire[`RegBus]    rom_addr_o,    // 
    output wire             rom_ce_o        // 
);
    // connect the port of IF/ID and ID 
    wire[`InstAddrBus]  pc;
    wire[`InstAddrBus]  id_pc_i;
    wire[`InstBus]      id_inst_i;
        
    // conenct the port of ID and ID/EX
    wire[`AluOpBus]     id_aluop_o;
    wire[`AluSelBus]    id_alusel_o;
    wire[`RegBus]       id_reg1_o;
    wire[`RegBus]       id_reg2_o;
    wire                id_wreg_o;
    wire[`RegAddrBus]   id_wd_o;

    // connect the port of ID/EX and EX
    wire[`AluOpBus]     ex_aluop_i;
    wire[`AluSelBus]    ex_alusel_i;
    wire[`RegBus]       ex_reg1_i;
    wire[`RegBus]       ex_reg2_i;
    wire                ex_wreg_i;
    wire[`RegAddrBus]   ex_wd_i;

    // connect the port of EX and EX/MEM
    wire                ex_wreg_o;
    wire[`RegAddrBus]   ex_wd_o;
    wire[`RegBus]       ex_wdata_o;

    // connect the port of EX/MEM and MEMORY
    wire                mem_wreg_i;
    wire[`RegAddrBus]   mem_wd_i;
    wire[`RegBus]       mem_wdata_i;

    // connect the port of MEMORY and MEM/WB
    wire                mem_wreg_o;
    wire[`RegAddrBus]   mem_wd_o;
    wire[`RegBus]       mem_wdata_o;

    // connect the port of MEM/WB and Write Back stage
    wire                wb_wreg_i;
    wire[`RegAddrBus]   wb_wd_i;
    wire[`RegBus]       wb_wdata_i;

    // connect the port of ID and Regfile
    wire                reg1_read;
    wire                reg2_read;
    wire[`RegBus]       reg1_data;
    wire[`RegBus]       reg2_data;
    wire[`RegAddrBus]   reg1_addr;
    wire[`RegAddrBus]   reg2_addr;

    // HILO data from MEMORY stage
    wire[`RegBus]       mem_hi_o;
    wire[`RegBus]       mem_lo_o;
    wire                mem_whilo_o;

    // HILO to Ex stage
    wire[`RegBus]       hi_o;
    wire[`RegBus]       lo_o;

    // HILO result data from EX stage to MEMORY stage
    wire[`RegBus]       ex_hi_i;
    wire[`RegBus]       ex_lo_i;
    wire                ex_whilo_i;

    // HILO result data from EX/MEM stage to MEM
    wire[`RegBus]       ex_hi_o;
    wire[`RegBus]       ex_lo_o;
    wire                ex_whilo_o;

    // HILO data from MEM to MEM/WB
    wire[`RegBus]       wb_hi_i;
    wire[`RegBus]       wb_lo_i;
    wire                wb_whilo_i;

    // Instantiate the pc_reg
    pc_reg pc_reg0(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .ce(rom_ce_o)
    );    

    assign rom_addr_o = pc;

    if_id if_id0(
        .clk(clk),
        .rst(rst),
        .if_pc(pc),
        .if_inst(rom_data_i),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );
    
    // Instantiate the ID
    id id0(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),

        // Input data from Regfile
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),

        // Input forwared data from EX stage
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),

        // Input forwarded data from memory stage
        .mem_wreg_i(mem_wreg_o),
        .mem_wdata_i(mem_wdata_o),
        .mem_wd_i(mem_wd_o),

        // Output data to Regfile
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),

        // Output data to ID/EX
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o)
    );

    // Instantiate the Regfile
    regfile regfile0(
        .clk(clk),
        .rst(rst),

        .we(wb_wreg_i),
        .waddr(wb_wd_i),
        .wdata(wb_wdata_i),
        .re1(reg1_read),
        .raddr1(reg1_addr),
        .rdata1(reg1_data),
        .re2(reg2_read),
        .raddr2(reg2_addr),
        .rdata2(reg2_data)
    );

    // Instantiate ID/EX
    id_ex id_ex0(
        .clk(clk),
        .rst(rst),

        // Input data from ID
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),

        // Output data to EX
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i)
    );

    // Instantiate EX
    ex ex0(
        .rst(rst),

        // Input data from ID/EX
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),
        
        // HILO data from register
        .hi_i(hi_o),
        .lo_i(lo_o),

        // HILO data from WriteBack stage
        .wb_hi_i(wb_hi_i),
        .wb_lo_i(wb_lo_i),
        .wb_whilo_i(wb_whilo_i),

        // HILO data from MEMORY stage
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
        .mem_whilo_i(mem_whilo_o),
        
        // Result data of HILO 
        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .whilo_o(ex_whilo_o),

        // Output data to EX/MEM
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o)
    );

    // Instantiate EX/MEM
    ex_mem ex_mem0(
        .clk(clk),
        .rst(rst),

        // Input data from EX
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        // HILO data from EX stage
        .ex_hi(ex_hi_i),
        .ex_lo(ex_lo_i),
        .ex_whilo(ex_whilo_i),

        // HILO data send to MEMORY stage
        .mem_hi(ex_hi_o),
        .mem_lo(ex_hi_o),
        .mem_whilo(ex_whilo_o),

        // Output data to MEM
        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i)
    );

    // Instantiate MEMORY
    mem mem0(
        .rst(rst),

        // Input data from EX/MEM
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        // HILO data from EX/MEM
        .hi_i(ex_hi_o),
        .lo_i(ex_lo_o),
        .whilo_i(ex_whilo_o),

        // HILO data to MEM/WB
        .hi_o(wb_hi_i),
        .lo_o(wb_lo_i),
        .whilo_o(wb_whilo_i),

        // Output data to MEM/WB
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o)
    );

    // Instantiate MEM/WB
    mem_wb mem_wb0(
        .clk(clk),
        .rst(rst),

        // Input data from MEMORY
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),

        // Output data to Write Back
        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i)
    );

    hilo_reg hilo_reg0(
        .clk(clk),
        .rst(rst),

        // Data from WB/MEM register
        .we(wb_whilo_i),
        .hi_i(wb_hi_i),
        .lo_i(wb_lo_i),

        // Data to EX stage
        .hi_o(hi_o),
        .lo_o(lo_o)
    );

endmodule

